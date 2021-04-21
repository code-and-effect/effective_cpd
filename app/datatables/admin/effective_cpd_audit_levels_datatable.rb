module Admin
  class EffectiveCpdAuditLevelsDatatable < Effective::Datatable
    datatable do
      order :title

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title

      col :days_to_submit, label: false
      col :days_to_review, label: false

      col :conflict_of_interest, label: false
      col :days_to_declare_conflict, label: false

      col :can_request_exemption, label: false
      col :days_to_request_exemption, label: false

      col :can_request_extension, label: false
      col :days_to_request_extension, label: false

      col :cpd_audit_sections, label: 'Sections', action: false
      col :cpd_audit_questions, label: 'Questions', action: false

      actions_col
    end

    collection do
      Effective::CpdAuditLevel.all.deep
    end
  end
end
