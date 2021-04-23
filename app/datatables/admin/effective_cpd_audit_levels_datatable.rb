module Admin
  class EffectiveCpdAuditLevelsDatatable < Effective::Datatable
    datatable do
      order :title

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title

      col :days_to_submit, visible: false
      col :days_to_review, visible: false

      col :conflict_of_interest, visible: false
      col :days_to_declare_conflict, visible: false

      col :can_request_exemption, visible: false
      col :days_to_request_exemption, visible: false

      col :can_request_extension, visible: false
      col :days_to_request_extension, visible: false

      col :cpd_audit_level_sections, label: 'Sections', action: false
      col :cpd_audit_level_questions, label: 'Questions', action: false

      actions_col
    end

    collection do
      Effective::CpdAuditLevel.all.deep
    end
  end
end
