# Displays available cpd_cycles that the current_user may complete

class EffectiveCpdDatatable < Effective::Datatable
  datatable do
    order :start_at

    col :start_at, visible: false

    col(:title, label: cpd_cycle_label.titleize)
    col :available_date, label: 'Available'

    actions_col(actions: []) do |cpd_cycle|
      statement = cpd_cycle.cpd_statements.where(user: current_user).first

      if statement.blank?
        dropdown_link_to('Start', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_cycle, :new, :start))
      elsif statement.completed?
        'Complete'
      else
        dropdown_link_to('Continue', effective_cpd.cpd_cycle_cpd_statement_build_path(cpd_cycle, statement, statement.next_step))
      end
    end
  end

  collection do
    raise('expected a current_user') unless current_user.present?
    Effective::CpdCycle.available
  end

end
