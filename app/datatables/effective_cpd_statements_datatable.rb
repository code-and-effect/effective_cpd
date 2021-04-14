# Displays past cpd statements that were completed by the user

class EffectiveCpdStatementsDatatable < Effective::Datatable
  datatable do
    order :cpd_cycle_id

    col(:cpd_cycle_id, label: cpd_cycle_label.titleize) do |statement|
      statement.cpd_cycle.to_s
    end

    col :completed_at, label: 'Completed'

    actions_col(actions: []) do |cpd_statement|
      dropdown_link_to('Show', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_statement.cpd_cycle, cpd_statement, cpd_statement.last_completed_step))
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    Effective::CpdStatement.completed.where(user: current_user).includes(:cpd_cycle)
  end

end
