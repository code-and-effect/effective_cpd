Rails.application.routes.draw do
  mount EffectiveCpd::Engine => '/', as: 'effective_cpd'
end

EffectiveCpd::Engine.routes.draw do
  scope module: 'effective' do
  end

  namespace :admin do
  end

end
