module Admin
  class EffectiveCpdActivitiesDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :cpd_category

      col :position, label: 'Num' do |cpd_activity|
        cpd_activity.position.to_i + 1
      end

      col :title do |cpd_activity|
        content_tag(:div, cpd_activity.title) + raw(cpd_activity.body)
      end

      col :formula do |cpd_activity|
        content_tag(:div, cpd_activity.formula, style: 'white-space: nowrap;')
      end

      col :amount_label, label: 'Amount'
      col :amount2_label, label: 'Amount2'

      col :max_credits_per_cycle, label: 'Credits' do |cpd_activity|
        if cpd_activity.max_credits_per_cycle
          "max #{cpd_activity.max_credits_per_cycle}"
        end
      end

      col :max_cycles_can_carry_forward, label: 'Carry' do |cpd_activity|
        if cpd_activity.max_cycles_can_carry_forward
          "upto #{cpd_activity.max_cycles_can_carry_forward}"
        end
      end

      actions_col
    end

    collection do
      Effective::CpdActivity.all.deep
    end
  end
end
