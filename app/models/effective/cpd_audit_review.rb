module Effective
  class CpdAuditReview < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_audit
    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true    # Auditor

    has_many :cpd_audit_review_items, -> { CpdAuditReviewItem.sorted }, inverse_of: :cpd_audit_review
    accepts_nested_attributes_for :cpd_audit_review_items, reject_if: :all_blank, allow_destroy: true

    if respond_to?(:log_changes)
      log_changes(to: :cpd_audit, except: :wizard_steps)
    end

    acts_as_email_form
    acts_as_tokened

    acts_as_wizard(
      start: 'Start',
      information: 'Information',
      instructions: 'Instructions',

      # Optional based on cpd_audit_level options
      conflict: 'Conflict of Interest',

      waiting: 'Waiting on Auditee Submission',

      statements: 'Review CPD Statements',
      # ... There will be one step per cpd_statement here. "statement1"

      questionnaire: 'Review Questionnaire Responses',
      # ... There will be one step per cpd_audit_level_sections here

      recommendation: 'Recommendation',
      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    effective_resource do
      token                     :string
      due_date                  :date

      # Auditor response
      conflict_of_interest          :boolean
      conflict_of_interest_reason   :text

      # Rolling comments
      comments                  :text

      # Recommendation Step
      recommendation            :string

      # Status Dates
      submitted_at              :datetime

      # acts_as_statused
      # I'm not using acts_as_statused yet, but I probably will later
      status                  :string
      status_steps            :text

      # Wizard Progress
      wizard_steps              :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit, :cpd_audit_level, :user) }
    scope :sorted, -> { order(:id) }

    scope :available, -> { where(submitted_at: nil) }
    scope :completed, -> { where.not(submitted_at: nil) }

    before_validation(if: -> { new_record? }) do
      self.cpd_audit_level ||= cpd_audit&.cpd_audit_level
      self.due_date ||= deadline_to_review()
    end

    validate(if: -> { recommendation.present? }) do
      unless cpd_audit_level.recommendations.include?(recommendation)
        self.errors.add(:recommendation, 'must exist in this audit level')
      end
    end

    after_commit(on: :create) { send_email(:cpd_audit_review_opened) }
    after_commit(on: :destroy) { cpd_audit.review! }

    def to_s
      'audit review'
    end

    def to_s
      persisted? ? "#{cpd_audit_level} Audit Review by #{user}" : 'audit review'
    end

    # Find or build
    def cpd_audit_review_item(item)
      unless item.kind_of?(CpdAuditResponse) || item.kind_of?(CpdStatementActivity)
        raise("expected a cpd_audit_response or cpd_statement_activity")
      end

      cpd_audit_review_item = cpd_audit_review_items.find { |cari| cari.item == item }
      cpd_audit_review_item ||= cpd_audit_review_items.build(item: item)
    end

    # The dynamic CPD Statement review steps
    def auditee_cpd_statements
      cpd_audit.user.cpd_statements.select do |cpd_statement|
        cpd_statement.completed? && (submitted_at.blank? || cpd_statement.submitted_at < submitted_at)
      end
    end

    def cpd_statement(wizard_step)
      cpd_cycle_id = (wizard_step.to_s.split('statement').last.to_i rescue false)
      auditee_cpd_statements.find { |cpd_statement| cpd_statement.cpd_cycle_id == cpd_cycle_id }
    end

    def dynamic_wizard_statement_steps
      @statement_steps ||= auditee_cpd_statements.each_with_object({}) do |cpd_statement, h|
        h["statement#{cpd_statement.cpd_cycle_id}".to_sym] = "#{cpd_statement.cpd_cycle.to_s} Activities"
      end
    end

    # The dynamic CPD Audit Level Sections steps
    def cpd_audit_level_section(wizard_step)
      position = (wizard_step.to_s.split('section').last.to_i rescue false)
      cpd_audit_level.cpd_audit_level_sections.find { |section| (section.position + 1) == position }
    end

    def dynamic_wizard_questionnaire_steps
      @questionnaire_steps ||= cpd_audit_level.cpd_audit_level_sections.each_with_object({}) do |section, h|
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

      steps += [:waiting] unless ready?

      steps += [:statements] + dynamic_wizard_statement_steps.keys
      steps += [:questionnaire] + dynamic_wizard_questionnaire_steps.keys
      steps += [:recommendation, :submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    # Called by CpdAudit.extension_granted
    def extension_granted!
      self.due_date = deadline_to_review()
    end

    # Called by CpdAudit.submit!
    def ready!
      send_email(:cpd_audit_review_ready)
    end

    # Called by review wizard submit step
    def submit!
      update!(submitted_at: Time.zone.now)
      cpd_audit.review! # maybe go from submitted->removed

      send_email(:cpd_audit_review_submitted)
    end

    # When ready, the applicant review wizard hides the waiting step
    def ready?
      cpd_audit&.was_submitted?
    end

    def in_progress?
      submitted_at.blank?
    end

    def completed?
      submitted_at.present?
    end

    def email_form_defaults(action)
      { from: EffectiveCpd.mailer_sender }
    end

    def send_email(email)
      EffectiveCpd.send_email(email, self, email_form_params) unless email_form_skip?
      true
    end

    def deadline_to_conflict_of_interest
      cpd_audit.deadline_to_conflict_of_interest
    end

    def deadline_to_review
      return nil unless cpd_audit_level&.days_to_review.present?

      date = cpd_audit.deadline_to_submit
      return nil unless date.present?

      EffectiveResources.advance_date(date, business_days: cpd_audit_level.days_to_review)
    end

  end
end
