module Effective
  class CpdAuditSection < ActiveRecord::Base
    belongs_to :cpd_audit_level

    has_rich_text :top_content
    has_rich_text :bottom_content

    log_changes(to: :cpd_audit_level) if respond_to?(:log_changes)

    has_many :cpd_audit_questions, -> { CpdAuditQuestion.sorted }, inverse_of: :cpd_audit_section, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_questions, allow_destroy: true

    effective_resource do
      title     :string
      position  :integer

      timestamps
    end

    scope :deep, -> {
      with_rich_text_top_content
      .with_rich_text_bottom_content
      .includes(cpd_audit_questions: [:rich_text_body])
    }

    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_audit_level.present? }) do
      self.position ||= (cpd_audit_level.cpd_audit_sections.map(&:position).compact.max || -1) + 1
    end

    validates :title, presence: true
    validates :position, presence: true

    def to_s
      title.presence || 'audit section'
    end

  end
end
