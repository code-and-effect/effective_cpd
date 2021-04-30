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
      if resource.dynamic_wizard_statement_steps.keys.include?(the_step)
        render('cpd_statement', options)
      elsif resource.dynamic_wizard_questionnaire_steps.keys.include?(the_step)
        render('cpd_audit_level_section', options)
      else
        super
      end
    end

    def permitted_params
      case step
      when :start
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments)
      when :information
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments)
      when :instructions
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments)
      when :conflict
        params.require(:effective_cpd_audit_review)
          .permit(:current_step, :comments, :conflict_of_interest, :conflict_of_interest_reason)
      when :statements
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments)
      when :questionnaire
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments)
      when :recommendation
        params.require(:effective_cpd_audit_review).permit(:current_step, :comments, :recommendation)
      when :submit
        params.require(:effective_cpd_audit_review).permit(:current_step)
      when :complete
        raise('unexpected post to complete')
      else
        if step.to_s.start_with?('statement')
          params.require(:effective_cpd_audit_review).permit(:current_step, :comments,
            cpd_audit_review_items_attributes: [:id, :item_id, :item_type, :recommendation, :comments]
          )
        elsif step.to_s.start_with?('section')
          params.require(:effective_cpd_audit_review).permit(:current_step, :comments,
            cpd_audit_review_items_attributes: [:id, :item_id, :item_type, :recommendation, :comments]
          )
        else
          raise('unexpected step')
        end
      end
    end

  end
end
