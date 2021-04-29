module Admin
  class CpdAuditsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    submit :resolve_conflict, 'Resolve Conflict of Interest', success: -> {
      [
        "Successfully resolved #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip?)
      ].compact.join(' ')
    }

    submit :close, 'Close Audit', success: -> {
      [
        "Successfully closed #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip?)
      ].compact.join(' ')
    }

    submit :process_exemption, 'Process Exemption Request', success: -> {
      [
        "Successfully #{resource.status.gsub('_', ' ')} #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip?)
      ].compact.join(' ')
    }

    submit :process_exemption, 'Process Extension Request', success: -> {
      [
        "Successfully #{resource.status.gsub('_', ' ')} #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip?)
      ].compact.join(' ')
    }

    def permitted_params
      params.require(:effective_cpd_audit).permit!
    end

  end
end
