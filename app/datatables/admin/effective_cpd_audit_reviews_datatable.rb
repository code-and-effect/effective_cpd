module Admin
  class EffectiveCpdAuditReviewsDatatable < Effective::Datatable
    datatable do
      col :created_at, visible: false
      col :updated_at, visible: false
      col :id, visible: false

      col :cpd_audit
      col :user, label: 'Audit Reviewer'
      col :recommendation
      col :comments
      col :completed_at

      actions_col
    end

    collection do
      Effective::CpdAuditReview.all.deep
    end
  end
end
