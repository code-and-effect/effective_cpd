module Admin
  class EffectiveCpdAuditLevelsDatatable < Effective::Datatable
    datatable do
      order :title

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title
      col :cpd_audit_sections, label: 'Sections', action: false
      col :cpd_audit_questions, label: 'Questions', action: false

      actions_col
    end

    collection do
      Effective::CpdAuditLevel.all.deep
    end
  end
end
