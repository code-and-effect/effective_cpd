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
      col :submitted_at, label: 'Submitted'

      actions_col(edit: false)
    end

    collection do
      Effective::CpdAuditReview.all.deep
    end
  end
end
