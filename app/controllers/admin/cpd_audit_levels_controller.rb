module Admin
  class CpdAuditLevelsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    def permitted_params
      params.require(:effective_cpd_audit_level).permit!
    end

  end
end
