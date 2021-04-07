module Effective
  class CpdStatementsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope do
      cycle = Effective::CpdCycle.find(params[:cpd_cycle_id])
      Effective::CpdStatement.deep.where(cpd_cycle: cycle, user: current_user)
    end

    after_save(if: -> { step == :activities && params[:commit].to_s.include?('Activity') }) do
      flash[:success] = "Saved activity"
      @skip_to = :activities
    end

    # Enforce one statement per user per cycle. Redirect them to an existing statement for this cycle.
    before_action(only: [:new, :show]) do
      cycle = Effective::CpdCycle.find(params[:cpd_cycle_id])
      existing = Effective::CpdStatement.where(cpd_cycle: cycle, user: current_user).where.not(id: resource).first

      if existing&.completed?
        flash[:danger] = "You have already completed a statement for this #{cpd_cycle_label}."
        redirect_to(root_path)
      elsif existing.present?
        flash[:success] = "You have been redirected to the #{resource_wizard_step_title(existing.next_step)} step."
        redirect_to effective_cpd.cpd_cycle_cpd_statement_build_path(existing.cpd_cycle, existing, existing.next_step)
      end
    end

    # Enforce availability
    before_action(only: [:show, :update]) do
      cycle = resource.cpd_cycle

      unless cycle.available?
        flash[:danger] = begin
          if cycle.ended?
            "This #{cpd_cycle_label} has ended"
          elsif !cycle.started?
            "This #{cpd_cycle_label} has not yet started"
          else
            "This #{cpd_cycle_label} is unavailable"
          end
        end

        redirect_to(root_path)
      end
    end

    def permitted_params
      case step
      when :start
        params.require(:effective_cpd_statement).permit(:current_step)
      when :activities
        params.require(:effective_cpd_statement).permit(
          :current_step, cpd_statement_activities_attributes: [
            :id, :cpd_category_id, :cpd_activity_id, :amount, :amount2, :description, files: []
          ]
        )
      when :agreements
        params.require(:effective_cpd_statement).permit(:current_step)
      when :submit
        params.require(:effective_cpd_statement).permit(:current_step)
      when :complete
        raise('unexpected post to complete')
      else
        raise('unexpected step')
      end
    end

  end
end
