module Effective
  class CpdAuditReview < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_audit
    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true    # Auditor

    log_changes(to: :cpd_audit, except: :step_progress) if respond_to?(:log_changes)

    if Rails.env.test? # So our tests can override the required_steps method
      cattr_accessor :test_required_steps
    end

    has_many :cpd_audit_review_items, -> { CpdAuditReviewItem.sorted }, inverse_of: :cpd_audit_review
    accepts_nested_attributes_for :cpd_audit_review_items, reject_if: :all_blank, allow_destroy: true

    acts_as_tokened

    acts_as_wizard(
      start: 'Start',
      conflict: 'Conflict of Interest',
      review: 'Review items',
      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    effective_resource do
      token                     :string

      # Auditor response
      conflict_of_interest          :boolean
      conflict_of_interest_reason   :text

      # Rolling comments
      comments                  :text

      # Recommendation Step
      recommendation            :string

      # Status Dates
      completed_at              :datetime

      # Wizard Progress
      wizard_steps              :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit, :cpd_audit_level, :user) }
    scope :sorted, -> { order(:id) }

    scope :available, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }

    before_validation(if: -> { new_record? }) do
      self.cpd_audit_level ||= cpd_audit&.cpd_audit_level
    end

    def to_s
      'audit review'
    end

    # Find or build
    def cpd_audit_review_item(item)
      unless item.kind_of?(CpdAuditResponse) || item.kind_of?(CpdStatementActivity)
        raise("expected a cpd_audit_response or cpd_statement_activity")
      end

      cpd_audit_review_item = cpd_audit_review_items.find { |cari| cari.item == item }
      cpd_audit_review_item ||= cpd_audit_review_items.build(item: item)
    end

    def dynamic_wizard_steps
      cpd_audit_level.cpd_audit_level_sections.each_with_object({}) do |section, h|
        h["section#{section.position+1}".to_sym] = section.title
      end
    end

    def can_visit_step?(step)
      return (step == :complete) if completed?  # Can only view complete step once submitted
      can_revisit_completed_steps(step)
    end

    def required_steps
      steps = [:start]

      steps << :conflict if cpd_audit_level.conflict_of_interest?

      if conflict_of_interest?
        return steps + [:submit, :complete]
      end

      steps += [:review] + dynamic_wizard_steps.keys + [:submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    def in_progress?
      completed_at.blank?
    end

    def completed?
      completed_at.present?
    end

  end
end
