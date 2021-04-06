module Effective
  class CpdCyclesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    def show
      cycle = Effective::CpdCycle.find(params[:id])
      EffectiveResources.authorize!(self, :show, cycle)

      statement = Effective::CpdStatement.where(cpd_cycle: cycle, user: current_user).first

      if statement.present?
        redirect_to effective_cpd.cpd_cycle_cpd_statement_build_path(cycle, statement, statement.next_step)
      else
        redirect_to effective_cpd.cpd_cycle_cpd_statement_build_path(cycle, :new, :start)
      end
    end

  end
end
