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
      information: 'Information',
      instructions: 'Instructions',

      # Optional based on cpd_audit_level options
      conflict: 'Conflict of Interest',

      statements: 'Review CPD Statements',
      # ... There will be one step per cpd_statement here. "statement1"

      questionaire: 'Review Questionnaire Responses',
      # ... There will be one step per cpd_audit_level_sections here

      recommendation: 'Recommendation',
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

    def to_s
      persisted? ? "#{cpd_audit_level} Audit Review by #{user}" : 'audit review'
    end

    def cpd_audit_level_section(wizard_step)
      position = (wizard_step.to_s.split('section').last.to_i rescue false)
      cpd_audit_level.cpd_audit_level_sections.find { |section| (section.position + 1) == position }
    end

    # Find or build
    def cpd_audit_review_item(item)
      unless item.kind_of?(CpdAuditResponse) || item.kind_of?(CpdStatementActivity)
        raise("expected a cpd_audit_response or cpd_statement_activity")
      end

      cpd_audit_review_item = cpd_audit_review_items.find { |cari| cari.item == item }
      cpd_audit_review_item ||= cpd_audit_review_items.build(item: item)
    end

    def dynamic_wizard_statement_steps
      cpd_audit.user.cpd_statements.sorted.last(3).each_with_object({}) do |cpd_statement, h|
        h["statement#{cpd_statement.cpd_cycle_id}".to_sym] = cpd_statement.cpd_cycle.to_s
      end
    end

    def dynamic_wizard_questionnaire_steps
      cpd_audit_level.cpd_audit_level_sections.each_with_object({}) do |section, h|
        h["section#{section.position+1}".to_sym] = section.title
      end
    end

    def dynamic_wizard_steps
      dynamic_wizard_statement_steps.merge(dynamic_wizard_questionnaire_steps)
    end

    def can_visit_step?(step)
      return (step == :complete) if completed?  # Can only view complete step once submitted
      can_revisit_completed_steps(step)
    end

    def required_steps
      steps = [:start, :information, :instructions]

      steps << :conflict if cpd_audit_level.conflict_of_interest?

      if conflict_of_interest?
        return steps + [:submit, :complete]
      end

      steps += [:statements] + dynamic_wizard_statement_steps.keys
      steps += [:questionaire] + dynamic_wizard_questionnaire_steps.keys
      steps += [:recommendation, :submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    # Called by wizard submit step
    def submit!
      update!(completed_at: Time.zone.now)
    end

    def in_progress?
      completed_at.blank?
    end

    def completed?
      completed_at.present?
    end

  end
end
