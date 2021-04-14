module Admin
  class EffectiveCpdStatementsDatatable < Effective::Datatable
    filters do
      scope :completed
      scope :draft
      scope :all
    end

    datatable do
      order :updated_at

      col :id, visible: false
      col :token, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle, label: cpd_cycle_label.titleize
      col :user
      col :completed_at
      col :score
      col :carry_forward

      actions_col
    end

    collection do
      Effective::CpdStatement.all.deep
    end
  end
end
