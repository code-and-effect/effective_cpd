module Effective
  class CpdAuditLevel < ActiveRecord::Base
    log_changes if respond_to?(:log_changes)

    has_many :cpd_audit_sections, -> { CpdAuditSection.sorted }, inverse_of: :cpd_audit_level, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_sections, allow_destroy: true

    has_many :cpd_audit_questions, -> { CpdAuditQuestion.sorted }, through: :cpd_audit_sections

    effective_resource do
      title                 :string

      conflict_of_interest    :boolean      # Feature flags
      can_request_exemption   :boolean
      can_request_extension   :boolean

      days_to_declare_conflict      :integer
      days_to_request_exemption     :integer
      days_to_request_extension     :integer

      days_to_submit                :integer  # For auditee to submit statement
      days_to_review                :integer  # For auditor/audit_review to be completed

      timestamps
    end

    scope :deep, -> { all }
    scope :sorted, -> { order(:title) }

    validates :title, presence: true

    def to_s
      title.presence || 'audit level'
    end

  end
end
