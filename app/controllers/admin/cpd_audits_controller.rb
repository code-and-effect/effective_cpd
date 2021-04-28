module Admin
  class CpdAuditsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    submit :close, 'Close Audit', success: -> {
      [
        "Successfully closed #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip?)
      ].compact.join(' ')
    }

    def permitted_params
      params.require(:effective_cpd_audit).permit!
    end

  end
end
