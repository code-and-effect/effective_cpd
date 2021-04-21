module Admin
  class EffectiveCpdAuditsDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :token, visible: false

      col :cpd_audit_level, label: 'Audit Level'
      col :user, label: 'Auditee'
      #col :audit_reviews, label: 'Auditor'

      col :notification_date, label: 'Date of Notification'
      col :extension_date, label: 'Approved Extension Date'

      col :status
      col :determination

      col :conflict_of_interest, visible: false
      col :conflict_of_interest_reason, visible: false

      col :exemption_request, visible: false
      col :exemption_request_reason, visible: false

      col :extension_request, visible: false
      col :extension_request_date, visible: false
      col :extension_request_reason, visible: false

      actions_col
    end

    collection do
      Effective::CpdAudit.all.deep
    end
  end
end
