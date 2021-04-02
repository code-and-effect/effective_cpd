Rails.application.routes.draw do
  mount EffectiveCpd::Engine => '/', as: 'effective_cpd'
end

EffectiveCpd::Engine.routes.draw do
  scope module: 'effective' do
  end

  namespace :admin do
    resources :cpd_categories, except: [:show]
    resources :cpd_activities, except: [:show]
    resources :cpd_cycles, except: [:show]
    resources :cpd_rules, except: [:show]
  end

end
