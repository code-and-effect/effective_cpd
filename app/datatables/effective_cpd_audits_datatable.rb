# Displays cpd audits for this user

class EffectiveCpdAuditsDatatable < Effective::Datatable
  datatable do
    order :notification_date

    col :token, visible: false

    col :cpd_audit_level, label: 'Audit'
    col :notification_date, label: 'Date of Notification'
    col :status
    col :determination

    actions_col(actions: []) do |cpd_audit|
      if cpd_audit.opened?
        dropdown_link_to('Start', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.next_step))
      elsif cpd_audit.audited?
        dropdown_link_to('Show', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.last_completed_step))
      else
        dropdown_link_to('Continue', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.next_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    Effective::CpdAudit.where(user: current_user)
  end

end
