# Displays cpd audits for this auditor reviewer user

class EffectiveCpdAvailableAuditReviewsDatatable < Effective::Datatable
  datatable do
    order :due_date

    col :token, visible: false

    col :cpd_audit_level, label: 'Audit'
    col :due_date
    col :user, label: 'Auditee', action: false

    col :ready_to_review do |cpd_audit|
      cpd_audit.was_submitted? ? 'Yes' : 'No'
    end

    actions_col(actions: []) do |cpd_audit|
      cpd_audit_review = cpd_audit.cpd_audit_reviews.find { |r| r.user_id == current_user.id }

      if cpd_audit_review.wizard_steps.blank?
        dropdown_link_to('Start', effective_cpd.cpd_audit_review_build_path(cpd_audit_review, cpd_audit_review.next_step))
      else
        dropdown_link_to('Continue', effective_cpd.cpd_audit_review_build_path(cpd_audit_review, cpd_audit_review.next_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?

    reviews = Effective::CpdAuditReview.available.where(user: current_user)

    Effective::CpdAudit.available.includes(:cpd_audit_reviews)
      .where(id: reviews.select('cpd_audit_id as id'))
  end

end
