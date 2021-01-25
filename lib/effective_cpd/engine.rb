module EffectiveCpd
  class Engine < ::Rails::Engine
    engine_name 'effective_cpd'

    # Set up our default configuration options.
    initializer 'effective_cpd.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_cpd.rb")
    end

  end
end
