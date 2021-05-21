module Admin
  class CpdSpecialRulesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    def permitted_params
      params.require(:effective_cpd_special_rule).permit!
    end

  end
end
