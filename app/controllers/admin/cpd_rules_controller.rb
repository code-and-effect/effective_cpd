module Admin
  class CpdRulesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    if (config = EffectiveCpd.layout)
      layout(config.kind_of?(Hash) ? config[:admin] : config)
    end

    def permitted_params
      params.require(:effective_cpd_rule).permit!
    end

  end
end
