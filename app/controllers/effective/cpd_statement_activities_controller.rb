module Effective
  class CpdStatementActivitiesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { CpdStatement.find(params[:cpd_statement_id]).cpd_statement_activities }

    after_save do
      CpdScorer.new(user: resource.cpd_statement.user).score!
    end

    def permitted_params
      params.require(:effective_cpd_statement_activity).permit(
        :id, :cpd_category_id, :cpd_activity_id, :amount, :amount2, :description, files: []
      )
    end

  end
end
