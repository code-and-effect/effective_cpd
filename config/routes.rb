Rails.application.routes.draw do
  mount EffectiveCpd::Engine => '/', as: 'effective_cpd'
end

EffectiveCpd::Engine.routes.draw do
  scope module: 'effective' do
    resources :cpd_cycles, path: "cpd_#{EffectiveCpd.cycle_label.pluralize}", only: [:show] do
      resources :cpd_statements, path: :statements, only: [:new, :show] do
        resources :build, controller: :cpd_statements, only: [:show, :update]
      end
    end

    resources :cpd_statements, only: [] do
      resources :cpd_statement_activities, except: [:index, :show]
    end

  end

  namespace :admin do
    resources :cpd_categories, except: [:show]
    resources :cpd_activities, except: [:show]
    resources :cpd_cycles, except: [:show]
    resources :cpd_rules, only: [:index]
  end

end
