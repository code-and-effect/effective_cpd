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

    scope :in_progress, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }

    def to_s
      'audit review'
    end

    def in_progress?
      completed_at.blank?
    end

    def completed?
      completed_at.present?
    end

  end
end
