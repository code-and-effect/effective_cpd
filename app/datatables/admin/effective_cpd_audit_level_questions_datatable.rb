module Admin
  class EffectiveCpdAuditLevelQuestionsDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :created_at, visible: false
      col :updated_at, visible: false
      col :id, visible: false

      col :cpd_audit_level_section

      col :position do |cpd_audit_level_question|
        cpd_audit_level_question.position.to_i + 1
      end

      col :title
      col :body
      col :required

      col :category, label: 'Type'
      col :cpd_audit_level_question_options, label: 'Options'

      actions_col
    end

    collection do
      Effective::CpdAuditLevelQuestion.all.deep
    end
  end
end
