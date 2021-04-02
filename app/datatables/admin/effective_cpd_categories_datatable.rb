module Admin
  class EffectiveCpdCategoriesDatatable < Effective::Datatable
    datatable do
      length :all
      reorder :position

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title do |cpd_category|
        content_tag(:div, cpd_category.title) + raw(cpd_category.body)
      end

      col :cpd_activities, label: 'Activities'

      actions_col
    end

    collection do
      Effective::CpdCategory.all.deep
    end
  end
end
