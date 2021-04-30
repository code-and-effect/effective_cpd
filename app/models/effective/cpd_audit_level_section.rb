module Effective
  class CpdAuditLevelSection < ActiveRecord::Base
    belongs_to :cpd_audit_level

    has_rich_text :top_content
    has_rich_text :bottom_content

    has_many :cpd_audit_level_questions, -> { CpdAuditLevelQuestion.sorted }, inverse_of: :cpd_audit_level_section, dependent: :destroy
    accepts_nested_attributes_for :cpd_audit_level_questions, allow_destroy: true

    has_many :cpd_audit_responses

    if respond_to?(:log_changes)
      log_changes(to: :cpd_audit_level, except: [:cpd_audit_responses])
    end

    effective_resource do
      title     :string
      position  :integer

      timestamps
    end

    scope :deep, -> {
      with_rich_text_top_content
      .with_rich_text_bottom_content
      .includes(cpd_audit_level_questions: [:rich_text_body])
    }

    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_audit_level.present? }) do
      self.position ||= (cpd_audit_level.cpd_audit_level_sections.map(&:position).compact.max || -1) + 1
    end

    validates :title, presence: true
    validates :position, presence: true

    before_destroy do
      if (count = cpd_audit_responses.length) > 0
        raise("#{count} audit responses belong to this section")
      end
    end

    def to_s
      title.presence || 'audit section'
    end

  end
end
