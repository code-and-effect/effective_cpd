module Admin
  class EffectiveCpdCategoriesDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :cpd_cycle

      col :position do |cpd_category|
        cpd_category.position.to_i + 1
      end

      col :title
      col :body

      actions_col
    end

    collection do
      Effective::CpdCategory.all.deep
    end
  end
end
