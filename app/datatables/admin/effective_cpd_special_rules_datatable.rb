module Admin
  class EffectiveCpdSpecialRulesDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle, label: cpd_cycle_label.titleize

      col :cpd_rules

      col :category
      col :max_credits_per_cycle, label: 'Max ' + cpd_credits_label.titleize

      actions_col
    end

    collection do
      cpd_cycle = Effective::CpdCycle.find(attributes[:cpd_cycle_id])
      Effective::CpdSpecialRule.all.deep.where(cpd_cycle: cpd_cycle)
    end
  end
end
