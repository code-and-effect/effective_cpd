module Effective
  class CpdAuditLevel < ActiveRecord::Base
    log_changes if respond_to?(:log_changes)

    has_many :cpd_audit_sections, -> { CpdAuditSection.sorted }, inverse_of: :cpd_audit_level, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_sections, allow_destroy: true

    has_many :cpd_audit_questions, -> { CpdAuditQuestion.sorted }, through: :cpd_audit_sections

    effective_resource do
      title       :string
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
