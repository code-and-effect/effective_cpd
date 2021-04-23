# Displays cpd audits for this auditee user

class EffectiveCpdCompletedAuditsDatatable < Effective::Datatable
  datatable do
    order :notification_date

    col :token, visible: false

    col :cpd_audit_level, label: 'Audit'
    col :notification_date, label: 'Date of Notification'
    col :status
    col :determination

    actions_col(actions: []) do |cpd_audit|
      dropdown_link_to('Show', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.last_completed_step))
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    Effective::CpdAudit.completed.where(user: current_user)
  end

end
