# Displays available cpd_cycles that the current_user may complete

class EffectiveCpdAvailableCyclesDatatable < Effective::Datatable
  datatable do
    order :start_at

    col :start_at, visible: false

    col(:title, label: cpd_cycle_label.titleize)
    col :available_date, label: 'Available'

    actions_col(actions: []) do |cpd_cycle|
      statement = cpd_cycle.cpd_statements.where(user: current_user).first

      if statement.blank?
        dropdown_link_to('Start', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_cycle, :new, :start))
      else
        dropdown_link_to('Continue', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_cycle, statement, statement.next_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    completed = Effective::CpdStatement.completed.where(user: current_user)
    Effective::CpdCycle.available.where.not(id: completed.select('cpd_cycle_id as id'))
  end

end
