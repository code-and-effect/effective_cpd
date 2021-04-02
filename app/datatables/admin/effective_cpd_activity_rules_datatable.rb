module Admin
  class EffectiveCpdActivityRulesDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle
      col :ruleable

      col :formula do |cpd_activity|
        content_tag(:div, cpd_activity.formula, style: 'white-space: nowrap;')
      end

      col :max_credits_per_cycle, label: cpd_credits_label.titleize do |cpd_rule|
        if cpd_rule.max_credits_per_cycle
          "max #{cpd_rule.max_credits_per_cycle}"
        end
      end

      col :max_cycles_can_carry_forward, label: cpd_cycles_label.titleize do |cpd_rule|
        if cpd_rule.max_cycles_can_carry_forward
          "max #{cpd_rule.max_cycles_can_carry_forward}"
        end
      end

      col :credit_description

      actions_col
    end

    collection do
      Effective::CpdRule.all.activities.deep
    end
  end
end
