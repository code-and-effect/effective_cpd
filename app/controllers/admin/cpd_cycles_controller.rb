module Admin
  class CpdCyclesController < ApplicationController
    layout EffectiveCpd.layout[:admin]

    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveCpd.authorize!(self, :admin, :effective_cpd) }

    include Effective::CrudController

    def permitted_params
      params.require(:effective_cpd_cycle).permit!
    end

  end
end
