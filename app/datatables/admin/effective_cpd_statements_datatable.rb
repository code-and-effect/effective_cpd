module Admin
  class EffectiveCpdStatementsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :draft, label: 'In Progress'
      scope :completed
    end

    datatable do
      order :updated_at

      col :id, visible: false
      col :token, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle, label: cpd_cycle_label.titleize
      col :user
      col :submitted_at, as: :date, label: 'Submitted'
      col :score
      col :carry_forward

      actions_col
    end

    collection do
      Effective::CpdStatement.all.deep
    end
  end
end
