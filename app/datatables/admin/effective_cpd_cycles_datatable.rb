module Admin
  class EffectiveCpdCyclesDatatable < Effective::Datatable
    datatable do
      order :start_at, :desc

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title
      col :start_at
      col :end_at
      col :required_score

      actions_col
    end

    collection do
      Effective::CpdCycle.all.deep
    end
  end
end
