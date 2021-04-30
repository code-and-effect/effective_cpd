module Admin
  class EffectiveCpdAuditReviewsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :available, label: 'In Progress'
      scope :completed
    end

    datatable do
      col :created_at, visible: false
      col :updated_at, visible: false
      col :id, visible: false

      col :cpd_audit
      col :user, label: 'Audit Reviewer'
      col :due_date
      col :submitted_at, as: :date, label: 'Submitted'
      col :conflict_of_interest
      col :recommendation
      col :comments

      actions_col(edit: false)
    end

    collection do
      Effective::CpdAuditReview.all.deep
    end
  end
end
