module Effective
  class CpdAuditReview < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_audit
    belongs_to :cpd_audit_level
    belongs_to :user, polymorphic: true    # Auditor

    log_changes(to: :cpd_audit, except: :wizard_steps) if respond_to?(:log_changes)

    if Rails.env.test? # So our tests can override the required_steps method
      cattr_accessor :test_required_steps
    end

    has_many :cpd_audit_review_items, -> { CpdAuditReviewItem.sorted }, inverse_of: :cpd_audit_review
    accepts_nested_attributes_for :cpd_audit_review_items, reject_if: :all_blank, allow_destroy: true

    acts_as_email_form
    acts_as_tokened

    acts_as_wizard(
      start: 'Start',
      information: 'Information',
      instructions: 'Instructions',

      # Optional based on cpd_audit_level options
      conflict: 'Conflict of Interest',

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

      # Auditor response
      conflict_of_interest          :boolean
      conflict_of_interest_reason   :text

      # Rolling comments
      comments                  :text

      # Recommendation Step
      recommendation            :string

      # Status Dates
      submitted_at              :datetime

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
    end

    after_commit(on: :create) do
      send_email(:cpd_audit_review_opened) if email_form_action
    end

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

      steps += [:statements] + dynamic_wizard_statement_steps.keys
      steps += [:questionnaire] + dynamic_wizard_questionnaire_steps.keys
      steps += [:recommendation, :submit, :complete]

      steps
    end

    def wizard_step_title(step)
      WIZARD_STEPS[step] || dynamic_wizard_steps.fetch(step)
    end

    # Called by wizard submit step
    def submit!
      update!(submitted_at: Time.zone.now)
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

    private

    def send_email(email)
      EffectiveCpd.send_email(email, self, email_form_params) unless email_form_skip?
      true
    end

  end
end
