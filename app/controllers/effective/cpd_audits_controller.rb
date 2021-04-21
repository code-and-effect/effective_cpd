module Effective
  class CpdAuditsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope do
      Effective::CpdAudit.deep.where(user: current_user)
    end

    def permitted_params
      case step
      when :start
        params.require(:effective_cpd_audit).permit(:current_step)
      when :submit
        params.require(:effective_cpd_audit).permit(:current_step)
      when :complete
        raise('unexpected post to complete')
      else
        raise('unexpected step')
      end
    end

  end
end
