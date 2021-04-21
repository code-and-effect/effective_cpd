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
      :waiting,               # Waiting on exemption or extension request
      :readied,               # Ready for auditee to complete questions.
      :submitted,             # Audittee has completed questionaire submitted. Audittee is done.
      :reviewed,              # All audit reviews completed. Ready for a determination.
      :audited                # Determination made by admin and/or audit committee. Exit state. All done.
    )

    acts_as_wizard(
      start: 'Start',
      information: 'Information',
      instructions: 'Instructions',

      # These 4 steps are determined by audit_level settings
      conflict: 'Conflict of Interest',
      exemption: 'Request Exemption',
      extension: 'Request Extension',
      waiting: 'Waiting on Request',

      questionaire: 'Questionaire',
      # ... There will be one step per cpd_audit_sections here
      files: 'Upload Resume',

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
      persisted? ? "#{cpd_audit_level} audit of #{user}" : 'audit'
    end

    acts_as_wizard(
      start: 'Start',
      information: 'Information',
      instructions: 'Instructions',

      # These 4 steps are determined by audit_level settings
      conflict: 'Conflict of Interest',
      exemption: 'Request Exemption',
      extension: 'Request Extension',
      waiting: 'Waiting on Request',

      questionaire: 'Questionaire',
      # ... There will be one step per cpd_audit_sections here
      files: 'Upload Resume',

      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    def dynamic_wizard_steps
      cpd_audit_level.cpd_audit_sections.each_with_object({}) do |section, h|
        h["section#{section.position+1}".to_sym] = section.title
      end
    end

    def required_steps
      steps = [:start, :information, :instructions]

      steps += [
        (:conflict if cpd_audit_level.conflict_of_interest?),
        (:exemption if cpd_audit_level.can_request_exemption?),
        (:extension if cpd_audit_level.can_request_extension?),
      ].compact

      if exemption_request? || extension_request?
        steps += [:waiting]
      end

      steps += [:questionaire] + dynamic_wizard_steps.keys + [:files, :submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    def deadline_date
      (extension_date || notification_date)
    end

    # These methods are automatically called by acts_as_wizard wizard controller
    def start!
      started!
    end

    def conflict!
      conflict_of_interest? ? conflicted! : save!
    end

    def exemption!
      exemption_request? ? exemption_requested! : save!
    end

    def extension!
      extension_request? ? extension_requested! : save!
    end

    def submit!
      submitted!
    end

    # These methods are overrides of automatically created ones by acts_as_statused

  end
end
