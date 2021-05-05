module EffectiveCpd
  class Engine < ::Rails::Engine
    engine_name 'effective_cpd'

    # Set up our default configuration options.
    initializer 'effective_cpd.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_cpd.rb")
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    initializer 'effective_cpd.active_record' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(EffectiveCpdUser::Base)
      end
    end

  end
end
