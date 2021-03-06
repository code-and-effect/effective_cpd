# Displays cpd audits for this auditor reviewer user

class EffectiveCpdCompletedAuditReviewsDatatable < Effective::Datatable
  datatable do
    order :notification_date

    col :token, visible: false

    col :cpd_audit_level, label: 'Audit'
    col :notification_date, label: 'Date of Notification'
    col :user, label: 'Auditee', action: false

    col :recommendation do |cpd_audit|
      cpd_audit.cpd_audit_reviews.find { |r| r.user_id == current_user.id }.recommendation
    end

    actions_col(actions: []) do |cpd_audit|
      cpd_audit_review = cpd_audit.cpd_audit_reviews.find { |r| r.user_id == current_user.id }
      dropdown_link_to('Show', effective_cpd.cpd_audit_review_build_path(cpd_audit_review, cpd_audit_review.next_step))
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?

    reviews = Effective::CpdAuditReview.completed.where(user: current_user)

    Effective::CpdAudit.includes(:cpd_audit_reviews)
      .where(id: reviews.select('cpd_audit_id as id'))
  end

end
