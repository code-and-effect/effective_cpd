module Effective
  class CpdAuditsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope do
      Effective::CpdAudit.deep.where(user: current_user)
    end

    # Reuse the same view for all cpd_audit_level_section steps
    # https://github.com/zombocom/wicked/blob/v1.3.4/lib/wicked/controller/concerns/render_redirect.rb#L32
    def render_step(the_step, options = {}, params = {})
      return super unless resource.dynamic_wizard_steps.keys.include?(the_step)
      render('cpd_audit_level_section', options)
    end

    def permitted_params
      case step
      when :start
        params.require(:effective_cpd_audit).permit(:current_step)
      when :information
        params.require(:effective_cpd_audit).permit(:current_step)
      when :instructions
        params.require(:effective_cpd_audit).permit(:current_step)
      when :conflict
        params.require(:effective_cpd_audit)
          .permit(:current_step, :conflict_of_interest, :conflict_of_interest_reason)
      when :exemption
        params.require(:effective_cpd_audit)
          .permit(:current_step, :exemption_request, :exemption_request_reason)
      when :extension
        params.require(:effective_cpd_audit)
          .permit(:current_step, :extension_request, :extension_request_date, :extension_request_reason)
      when :questionnaire
        params.require(:effective_cpd_audit).permit(:current_step)
      when :files
        params.require(:effective_cpd_audit).permit(:current_step, files: [])
      when :submit
        params.require(:effective_cpd_audit).permit(:current_step)
      when :complete
        raise('unexpected post to complete')
      else
        raise('unexpected step') unless step.to_s.start_with?('section')

        params.require(:effective_cpd_audit).permit(:current_step,
          cpd_audit_responses_attributes: [
            :id, :cpd_audit_id, :cpd_audit_level_question_id, :date, :email, :number, :long_answer, :short_answer, :upload_file, cpd_audit_level_question_option_ids: []
          ]
        )
      end
    end

  end
end
