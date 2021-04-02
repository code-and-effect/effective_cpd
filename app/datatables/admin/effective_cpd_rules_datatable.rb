module Admin
  class EffectiveCpdRulesDatatable < Effective::Datatable
    filters do
      scope :categories
      scope :activities
      scope :unavailable
      scope :all
    end

    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :cpd_cycle,label: cpd_cycle_label.titleize

      col :ruleable, label: 'Category or Activity', search: {
        collection: {
          'Categories' => Effective::CpdCategory.sorted,
          'Activities' => Effective::CpdActivity.sorted,
        },
        polymorphic: true
      }

      col :formula do |cpd_activity|
        content_tag(:div, cpd_activity.formula, style: 'white-space: nowrap;')
      end

      col :credit_description

      col :max_credits_per_cycle, label: 'Max ' + cpd_credits_label.titleize
      col :max_cycles_can_carry_forward, label: 'Max ' + cpd_cycles_label.titleize

      col :unavailable

      actions_col
    end

    collection do
      Effective::CpdRule.all.deep
    end
  end
end
