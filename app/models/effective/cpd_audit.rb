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

    if respond_to?(:log_changes)
      log_changes(except: [:wizard_steps, :cpd_audit_reviews])
    end

    acts_as_email_form
    acts_as_tokened

    COMPLETED_STATES = [:exemption_granted, :closed]

    WAITING_ON_ADMIN_STATES = [:conflicted, :exemption_requested, :extension_requested, :reviewed]
    WAITING_ON_REVIEWERS_STATES = [:submitted]
    WAITING_ON_AUDITEE_STATES = [:opened, :started, :conflicted_resolved, :exemption_denied, :extension_granted, :extension_denied]

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
      due_date                 :date     # Computed due date based on notification and extension date

      # Important dates
      notification_date        :date     # Can be set on CpdAudits#new, but basically created_at
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
      closed_at               :datetime

      # Acts as tokened
      token                   :string

      # Acts as Wizard
      wizard_steps            :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_level, user: [:cpd_statements], cpd_audit_reviews: [:cpd_audit_level, :user, :cpd_audit_review_items]) }
    scope :sorted, -> { order(:id) }

    scope :draft, -> { where(submitted_at: nil) }
    scope :available, -> { where.not(status: COMPLETED_STATES) }
    scope :completed, -> { where(status: COMPLETED_STATES) }

    scope :waiting_on_admin, -> { where(status: WAITING_ON_ADMIN_STATES) }
    scope :waiting_on_auditee, -> { where(status: WAITING_ON_AUDITEE_STATES) }
    scope :waiting_on_reviewers, -> { where(status: WAITING_ON_REVIEWERS_STATES) }

    before_validation(if: -> { new_record? }) do
      self.notification_date ||= Time.zone.now
      self.due_date ||= deadline_to_submit()
    end

    validates :notification_date, presence: true
    validates :determination, presence: true, if: -> { closed? }

    validates :conflict_of_interest_reason, presence: true, if: -> { conflict_of_interest? }
    validates :exemption_request_reason, presence: true, if: -> { exemption_request? }
    validates :extension_request_date, presence: true, if: -> { extension_request? }
    validates :extension_request_reason, presence: true, if: -> { extension_request? }

    validate(if: -> { determination.present? }) do
      unless cpd_audit_level.determinations.include?(determination)
        self.errors.add(:determination, 'must exist in this audit level')
      end
    end

    # If we're submitted. Check if we can go into reviewed?
    before_save(if: -> { submitted? }) { review! }

    after_commit(on: :create) do
      send_email(:cpd_audit_opened)
    end

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
      return started! unless conflict_of_interest?

      update!(status: :conflicted)
      send_email(:cpd_audit_conflicted)
    end

    # Admin action
    def resolve_conflict!
      wizard_steps[:conflict] = nil   # Have them complete the conflict step again.

      assign_attributes(conflict_of_interest: false, conflict_of_interest_reason: nil)
      conflicted_resolved!

      send_email(:cpd_audit_conflict_resolved)
      true
    end

    # Auditee wizard action
    def exemption!
      return started! unless exemption_request?

      update!(status: :exemption_requested)
      send_email(:cpd_audit_exemption_request)
    end

    # Admin action
    def process_exemption!
      case admin_process_request
      when 'Granted' then grant_exemption!
      when 'Denied' then deny_exemption!
      else
        self.errors.add(:admin_process_request, "can't be blank"); save!
      end
    end

    def grant_exemption!
      wizard_steps[:submit] ||= Time.zone.now
      submitted! && exemption_granted!
      send_email(:cpd_audit_exemption_granted)
    end

    def deny_exemption!
      assign_attributes(exemption_request: false)
      exemption_denied!
      send_email(:cpd_audit_exemption_denied)
    end

    # Auditee wizard action
    def extension!
      return started! unless extension_request?

      update!(status: :extension_requested)
      send_email(:cpd_audit_extension_request)
    end

    # Admin action
    def process_extension!
      case admin_process_request
      when 'Granted' then grant_extension!
      when 'Denied' then deny_extension!
      else
        self.errors.add(:admin_process_request, "can't be blank"); save!
      end
    end

    def grant_extension!
      self.extension_date = extension_request_date
      self.due_date = deadline_to_submit()

      cpd_audit_reviews.each { |cpd_audit_review| cpd_audit_review.extension_granted! }
      extension_granted!
      send_email(:cpd_audit_extension_granted)
    end

    def deny_extension!
      assign_attributes(extension_request: false)
      extension_denied!
      send_email(:cpd_audit_extension_denied)
    end

    # Auditee wizard action
    def submit!
      submitted!
      cpd_audit_reviews.each { |cpd_audit_review| cpd_audit_review.ready! }
      send_email(:cpd_audit_submitted)
    end

    # Called in a before_save. Intended for applicant_review to call in its submit! method
    def review!
      return false unless submitted?
      return false unless cpd_audit_reviews.present? && cpd_audit_reviews.all?(&:completed?)

      reviewed!
      send_email(:cpd_audit_reviewed)
    end

    # Admin action
    def close!
      closed!
      send_email(:cpd_audit_closed)
    end

    def email_form_defaults(action)
      { from: EffectiveCpd.mailer_sender }
    end

    def send_email(email)
      EffectiveCpd.send_email(email, self, email_form_params) unless email_form_skip?
      true
    end

    def deadline_to_conflict_of_interest
      return nil unless cpd_audit_level&.conflict_of_interest?
      return nil unless cpd_audit_level.days_to_declare_conflict.present?

      date = (notification_date || created_at || Time.zone.now)
      EffectiveResources.advance_date(date, business_days: cpd_audit_level.days_to_declare_conflict)
    end

    def deadline_to_exemption
      return nil unless cpd_audit_level&.can_request_exemption?
      return nil unless cpd_audit_level.days_to_request_exemption.present?

      date = (notification_date || created_at || Time.zone.now)
      EffectiveResources.advance_date(date, business_days: cpd_audit_level.days_to_request_exemption)
    end

    def deadline_to_extension
      return nil unless cpd_audit_level&.can_request_extension?
      return nil unless cpd_audit_level.days_to_request_extension.present?

      date = (notification_date || created_at || Time.zone.now)
      EffectiveResources.advance_date(date, business_days: cpd_audit_level.days_to_request_extension)
    end

    def deadline_to_submit
      return nil unless cpd_audit_level&.days_to_submit.present?

      date = (extension_date || notification_date || created_at || Time.zone.now)
      EffectiveResources.advance_date(date, business_days: cpd_audit_level.days_to_submit)
    end

  end
end
