module Admin
  class EffectiveCpdCategoryRulesDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle
      col :ruleable

      col :max_credits_per_cycle, label: cpd_credits_label.titleize do |cpd_rule|
        if cpd_rule.max_credits_per_cycle
          "max #{cpd_rule.max_credits_per_cycle}"
        end
      end

      col :credit_description

      actions_col
    end

    collection do
      Effective::CpdRule.all.categories.deep
    end
  end
end
