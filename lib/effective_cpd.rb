require 'effective_resources'
require 'effective_datatables'
require 'effective_cpd/engine'
require 'effective_cpd/version'

module EffectiveCpd

  def self.config_keys
    [
      :cpd_cycles_table_name, :cpd_categories_table_name, :cpd_activities_table_name,
      :cycle_label, :credit_label, :layout, :mailer
    ]
  end

  include EffectiveGem

end
