# Displays cpd audits for this auditee user

class EffectiveCpdAvailableAuditsDatatable < Effective::Datatable
  datatable do
    order :due_date

    col :token, visible: false

    col :cpd_audit_level, label: 'Audit'
    col :due_date
    col :status
    col :determination

    actions_col(actions: []) do |cpd_audit|
      if cpd_audit.opened?
        dropdown_link_to('Start', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.next_step))
      elsif cpd_audit.was_submitted?
        dropdown_link_to('Show', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.last_completed_step))
      else
        dropdown_link_to('Continue', effective_cpd.cpd_audit_build_path(cpd_audit, cpd_audit.next_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    Effective::CpdAudit.available.where(user: current_user)
  end

end
