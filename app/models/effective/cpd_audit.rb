module Effective
  class CpdAudit < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true  # The user being audited

    has_many :cpd_audit_reviews, -> { order(:id) }, inverse_of: :cpd_audit, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_reviews

    has_many_attached :files
    log_changes(except: :step_progress) if respond_to?(:log_changes)

    if Rails.env.test? # So our tests can override the required_steps method
      cattr_accessor :test_required_steps
    end

    acts_as_tokened

    acts_as_statused(
      :opened,                # Just Opened
      :started,               # First screen clicked
      :conflicted,            # Auditee declared conflict of interest
      :exemption_requested,   # Auditee has requested an exemption
      :exemption_granted,     # Exemption granted -> Audit is cancelled
      :exemption_denied,      # Exemption denied
      :extension_requested,   # Audittee has requested an extension
      :extension_granted,     # Extension granted
      :extension_denied,      # Extension denied
      :waiting,               # Waiting on auditer reviews conflict of interest
      :readied,               # Ready for auditee to submit
      :submitted,             # Audittee has completed questionaire
      :reviewed,              # All audit reviews completed
      :audited                # Set by admin. Exit state. All done.
    )

    acts_as_wizard(
      start: 'Start',
      conflict: 'Conflict of Interest',
      exemption: 'Request Exemption',
      extension: 'Request Extension',
      waiting: 'Waiting on Request',
      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    effective_resource do
      # Important dates
      notification_date        :date     # created_at, but editable
      extension_date           :date     # set by admin if extension if granted

      # Final determination
      determination            :string

      # Auditee response
      conflict_of_interest          :boolean
      conflict_of_interest_reason   :text

      exemption_request             :boolean
      exemption_request_reason      :text

      extension_request             :boolean
      extension_request_date        :date
      extension_request_reason      :text

      # acts_as_statused
      status                  :string
      status_steps            :text

      # Status dates
      started_at              :datetime
      submitted_at            :datetime
      reviewed_at             :datetime
      audited_at              :datetime

      # Acts as tokened
      token                   :string

      # Acts as Wizard
      wizard_steps            :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_level, :user, cpd_audit_reviews: [:cpd_audit_review_items]) }

    scope :sorted, -> { order(:id) }

    scope :draft, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }

    before_validation(if: -> { new_record? }) do
      self.notification_date ||= Time.zone.now
    end

    validates :notification_date, presence: true

    def to_s
      'audit'
    end

    def deadline_date
      (extension_date || notification_date)
    end

    # We completed the questionaire
    def submit!
      submitted!
    end

  end
end
