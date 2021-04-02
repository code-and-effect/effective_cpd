module Admin
  class EffectiveCpdActivitiesDatatable < Effective::Datatable
    datatable do

      if attributes[:cpd_category_id]
        reorder :position
      end

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :cpd_category
      col :position, visible: false

      col :title do |cpd_activity|
        content_tag(:div, cpd_activity.title) + raw(cpd_activity.body)
      end

      col :amount_label, label: 'Amount'
      col :amount2_label, label: 'Amount2'
      col :require_file, label: 'Upload'

      actions_col
    end

    collection do
      Effective::CpdActivity.all.deep
    end
  end
end
