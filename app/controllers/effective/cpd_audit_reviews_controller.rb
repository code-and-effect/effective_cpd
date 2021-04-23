module Effective
  class CpdAuditReviewsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope do
      Effective::CpdAuditReview.deep.where(user: current_user)
    end

    # Reuse the same view for all cpd_audit_level_section steps
    # https://github.com/zombocom/wicked/blob/v1.3.4/lib/wicked/controller/concerns/render_redirect.rb#L32
    def render_step(the_step, options = {}, params = {})
      return super unless resource.dynamic_wizard_steps.keys.include?(the_step)
      render('cpd_audit_level_section', options)
    end

    def permitted_params
      return params.require(:effective_cpd_audit_review).permit!

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
