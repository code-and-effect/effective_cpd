module Effective
  class CpdAuditLevelQuestionOption < ActiveRecord::Base
    belongs_to :cpd_audit_level_question

    effective_resource do
      title         :text
      position      :integer

      timestamps
    end

    before_validation(if: -> { cpd_audit_level_question.present? }) do
      self.position ||= (cpd_audit_level_question.cpd_audit_level_question_options.map { |obj| obj.position }.compact.max || -1) + 1
    end

    scope :sorted, -> { order(:position) }

    validates :title, presence: true
    validates :position, presence: true

    def to_s
      title.presence || 'New Audit Question Option'
    end

  end
end
