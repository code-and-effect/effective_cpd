Rails.application.routes.draw do
  mount EffectiveCpd::Engine => '/', as: 'effective_cpd'
end

EffectiveCpd::Engine.routes.draw do
  scope module: 'effective' do
    # Statements wizard
    resources :cpd_cycles, path: "cpd_#{EffectiveCpd.cycle_label.pluralize.parameterize.underscore}", only: [:show] do
      resources :cpd_statements, path: :statements, only: [:new, :show] do
        resources :build, controller: :cpd_statements, only: [:show, :update]
      end
    end

    # CRUD StatementActivities
    resources :cpd_statements, only: [] do
      resources :cpd_statement_activities, except: [:index, :show]
    end

    # Audits Auditee wizard
    resources :cpd_audits, only: [:new, :show] do
      resources :build, controller: :cpd_audits, only: [:show, :update]
    end

    # Audits Auditor / Audit Reviewer wizard
    resources :cpd_audit_reviews, only: [:new, :show] do
      resources :build, controller: :cpd_audit_reviews, only: [:show, :update]
    end
  end

  namespace :admin do
    resources :cpd_categories, except: [:show]
    resources :cpd_activities, except: [:show]
    resources :cpd_cycles, except: [:show]
    resources :cpd_rules, only: [:index]

    resources :cpd_statements, only: [:index, :show]

    resources :cpd_audit_levels, except: [:show]
    resources :cpd_audit_level_questions, except: [:show]

    resources :cpd_audits, except: [:show, :destroy]
    resources :cpd_audit_reviews, except: [:edit, :update]
  end

end
