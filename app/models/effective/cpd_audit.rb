module Effective
  class CpdAudit < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    attr_accessor :admin_process_request
    ADMIN_PROCESS_REQUEST_OPTIONS = ['Granted', 'Denied']

    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true  # The user being audited

    has_many :cpd_audit_reviews, -> { order(:id) }, inverse_of: :cpd_audit, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_reviews, allow_destroy: true

    has_many :cpd_audit_responses, -> { order(:id) }, inverse_of: :cpd_audit, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_responses

    has_many_attached :files
    log_changes(except: :step_progress) if respond_to?(:log_changes)

    if Rails.env.test? # So our tests can override the required_steps method
      cattr_accessor :test_required_steps
    end

    acts_as_email_form
    acts_as_tokened

    COMPLETED_STATES = [:exemption_granted, :closed]

    acts_as_statused(
      :opened,                # Just Opened
      :started,               # First screen clicked
      :conflicted,            # Auditee has declared a conflict of interest
      :conflicted_resolved,   # The conflict of interest has been resolved
      :exemption_requested,   # Auditee has requested an exemption
      :exemption_granted,     # Exemption granted -> Audit is cancelled. Exit state.
      :exemption_denied,      # Exemption denied
      :extension_requested,   # Audittee has requested an extension
      :extension_granted,     # Extension granted
      :extension_denied,      # Extension denied
      :submitted,             # Audittee has completed questionnaire submitted. Audittee is done.
      :reviewed,              # All audit reviews completed. Ready for a determination.
      :closed                 # Determination made by admin and/or audit committee. Exit state. All done.
    )

    acts_as_wizard(
      start: 'Start',
      information: 'Information',
      instructions: 'Instructions',

      # These 4 steps are determined by audit_level settings
      conflict: 'Conflict of Interest',
      exemption: 'Request Exemption',
      extension: 'Request Extension',
      waiting: 'Waiting',

      questionnaire: 'Questionnaire',
      # ... There will be one step per cpd_audit_level_sections here
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
      audited_at              :datetime       # TODO: CHange to closed_at

      # Acts as tokened
      token                   :string

      # Acts as Wizard
      wizard_steps            :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_level, :user, cpd_audit_reviews: [:cpd_audit_review_items]) }

    scope :sorted, -> { order(:id) }

    scope :draft, -> { where(submitted_at: nil) }
    scope :available, -> { where.not(status: COMPLETED_STATES) }
    scope :completed, -> { where(status: COMPLETED_STATES) }

    before_validation(if: -> { new_record? }) do
      self.notification_date ||= Time.zone.now
    end

    # If we're submitted. Check if we can go into reviewed?
    before_save(if: -> { submitted? }) { review! }

    after_commit(on: :create) do
      send_email(:cpd_audit_opened) if email_form_action
    end

    validates :notification_date, presence: true
    validates :determination, presence: true, if: -> { closed? }

    def to_s
      persisted? ? "#{cpd_audit_level} Audit of #{user}" : 'audit'
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
      # ... There will be one step per cpd_audit_level_sections here
      files: 'Upload Resume',

      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    def dynamic_wizard_steps
      cpd_audit_level.cpd_audit_level_sections.each_with_object({}) do |section, h|
        h["section#{section.position+1}".to_sym] = section.title
      end
    end

    def can_visit_step?(step)
      return (step == :complete) if was_submitted?  # Can only view complete step once submitted
      can_revisit_completed_steps(step)
    end

    def required_steps
      steps = [:start, :information, :instructions]

      steps << :conflict if cpd_audit_level.conflict_of_interest?

      if conflicted?
        return steps + [:waiting, :submit, :complete]
      end

      steps << :exemption if cpd_audit_level.can_request_exemption?

      unless exemption_requested?
        steps << :extension if cpd_audit_level.can_request_extension?
      end

      if exemption_requested? || extension_requested?
        steps += [:waiting]
      end

      steps += [:questionnaire] + dynamic_wizard_steps.keys + [:files, :submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    def deadline_date
      (extension_date || notification_date)
    end

    def completed?
      COMPLETED_STATES.include?(status.to_sym)
    end

    def in_progress?
      COMPLETED_STATES.include?(status.to_sym) == false
    end

    def cpd_audit_level_section(wizard_step)
      position = (wizard_step.to_s.split('section').last.to_i rescue false)
      cpd_audit_level.cpd_audit_level_sections.find { |section| (section.position + 1) == position }
    end

    # Find or build
    def cpd_audit_response(cpd_audit_level_question)
      cpd_audit_response = cpd_audit_responses.find { |r| r.cpd_audit_level_question_id == cpd_audit_level_question.id }
      cpd_audit_response ||= cpd_audit_responses.build(cpd_audit: self, cpd_audit_level_question: cpd_audit_level_question)
    end

    # Auditee wizard action
    def start!
      started!
    end

    # Auditee wizard action
    def conflict!
      return save! unless conflict_of_interest?

      update!(status: :conflicted)
      send_email(:cpd_audit_conflicted) # Always
    end

    # Admin action
    def resolve_conflict!
      wizard_steps[:conflict] = nil   # Have them complete the conflict step again.

      assign_attributes(conflict_of_interest: false, conflict_of_interest_reason: nil)
      conflicted_resolved!

      send_email(:cpd_audit_conflict_resolved) if email_form_action
      true
    end

    # Auditee wizard action
    def exemption!
      return save! unless exemption_request?

      update!(status: :exemption_requested)
      send_email(:cpd_audit_exemption_request)
    end

    # Admin action
    def process_exemption!
      if admin_process_request.blank?
        self.errors.add(:admin_process_request, "can't be blank"); save!
      end

      if admin_process_request == 'Denied'
        assign_attributes(exemption_request: false)
        exemption_denied!
        send_email(:cpd_audit_exemption_denied) if email_form_action
      end

      if admin_process_request == 'Granted'
        wizard_steps[:submit] ||= Time.zone.now
        submitted! && exemption_granted!
        send_email(:cpd_audit_exemption_granted) if email_form_action
      end

      true
    end

    # Auditee wizard action
    def extension!
      return save! unless extension_request?

      update!(status: :extension_requested)
      send_email(:cpd_audit_extension_request) # Always
    end

    # Admin action
    def process_exemption!
      if admin_process_request.blank?
        self.errors.add(:admin_process_request, "can't be blank"); save!
      end

      if admin_process_request == 'Denied'
        assign_attributes(extension_request: false)
        extension_denied!
        send_email(:cpd_audit_extension_denied) if email_form_action
      end

      if admin_process_request == 'Granted'
        assign_attributes(extension_date: extension_request_date)
        extension_granted!
        send_email(:cpd_audit_extension_granted) if email_form_action
      end

      true
    end

    # Auditee wizard action
    def submit!
      submitted!

      send_email(:cpd_audit_submitted) # Always

      cpd_audit_reviews.each do |cpd_audit_review|
        cpd_audit_review.send_email(:cpd_audit_review_ready)
      end

      true
    end

    # Called in a before_save. Intended for applicant_review to call in its submit! method
    def review!
      return false unless submitted?
      return false unless cpd_audit_reviews.present? && cpd_audit_reviews.all?(&:completed?)

      reviewed!
      send_email(:cpd_audit_reviewed) # Always
    end

    # Admin action
    def close!
      closed!
      send_email(:cpd_audit_closed) if email_form_action
      true
    end

    def email_form_defaults(action)
      { from: EffectiveCpd.mailer_sender }
    end

    def send_email(email)
      EffectiveCpd.send_email(email, self, email_form_params) unless email_form_skip?
      true
    end

  end
end
