module Effective
  class CpdAudit < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true  # The user being audited

    #has_many :cpd_audit_reviews
    #has_many :cpd_audit_responses

    #has_many :cpd_statement_activities, -> { order(:id) }, inverse_of: :cpd_statement, dependent: :destroy
    #accepts_nested_attributes_for :cpd_statement_activities

    has_many_attached :files
    log_changes(except: :step_progress) if respond_to?(:log_changes)

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
      extension_date           :date     # set by admin if extension is granted

      # Final determination
      determination            :string

      # Auditee response
      conflict_of_interest     :boolean

      exemption_request        :text

      extension_request        :text
      extension_request_date   :date

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

    scope :deep, -> {
      includes(:cpd_audit_level, :cpd_cycle, :cpd_statement, :user)
      #includes(cpd_statement: [:cpd_cycle, :user, cpd_statement_activities: [:files_attachments, :cpd_category, :original, cpd_activity: [:rich_text_body]]]) }
    }

    scope :sorted, -> { order(:cpd_cycle, :cpd_statement_id) }

    scope :draft, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }

    before_validation(if: -> { new_record? }) do
      self.user ||= current_user
      self.cpd_cycle ||= cpd_statement&.cpd_cycle
    end

    # with_options(if: -> { current_step == :agreements }) do
    #   validates :confirm_read, acceptance: true
    #   validates :confirm_factual, acceptance: true
    # end

    # with_options(if: -> { current_step == :submit}) do
    #   validates :confirm_readonly, acceptance: true
    # end

    def to_s
      (cpd_audit_level || 'audit').to_s
    end

    # We completed the questionaire
    def submit!
      submitted!
    end

  end
end
