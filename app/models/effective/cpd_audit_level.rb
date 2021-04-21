module Effective
  class CpdAuditLevel < ActiveRecord::Base
    log_changes if respond_to?(:log_changes)

    has_many :cpd_audit_sections, -> { CpdAuditSection.sorted }, inverse_of: :cpd_audit_level, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_sections, allow_destroy: true

    has_many :cpd_audit_questions, -> { CpdAuditQuestion.sorted }, through: :cpd_audit_sections

    effective_resource do
      title                         :string

      days_to_submit                :integer  # For auditee to submit statement
      days_to_review                :integer  # For auditor/audit_review to be completed

      conflict_of_interest          :boolean      # Feature flags
      can_request_exemption         :boolean
      can_request_extension         :boolean

      days_to_declare_conflict      :integer
      days_to_request_exemption     :integer
      days_to_request_extension     :integer

      timestamps
    end

    scope :deep, -> { all }
    scope :sorted, -> { order(:title) }

    validates :title, presence: true

    validates :days_to_submit, numericality: { greater_than: 0, allow_nil: true }
    validates :days_to_submit, numericality: { greater_than: 0, allow_nil: true }

    validates :days_to_declare_conflict, presence: true, if: -> { conflict_of_interest? }
    validates :days_to_request_exemption, presence: true, if: -> { can_request_exemption? }
    validates :days_to_request_extension, presence: true, if: -> { can_request_extension? }

    validates :days_to_declare_conflict, numericality: { greater_than: 0, allow_nil: true }
    validates :days_to_request_exemption, numericality: { greater_than: 0, allow_nil: true }
    validates :days_to_request_extension, numericality: { greater_than: 0, allow_nil: true }

    def to_s
      title.presence || 'audit level'
    end

  end
end
