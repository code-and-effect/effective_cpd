# Displays past cpd statements that were completed by the user

class EffectiveCpdCompletedStatementsDatatable < Effective::Datatable
  datatable do
    order :cpd_cycle_id

    col(:cpd_cycle_id, label: 'Statement') do |statement|
      statement.cpd_cycle.to_s
    end

    col :submitted_at, as: :date, label: 'Submitted'
    col :score
    col :carry_forward

    unless attributes[:actions] == false
      actions_col(actions: []) do |cpd_statement|
        dropdown_link_to('Show', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_statement.cpd_cycle, cpd_statement, cpd_statement.last_completed_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    user = (current_user.class.find(attributes[:user_id]) if attributes[:user_id])
    Effective::CpdStatement.completed.where(user: user || current_user).includes(:cpd_cycle)
  end

end
