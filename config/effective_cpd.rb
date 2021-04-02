EffectiveCpd.setup do |config|
  config.cpd_cycles_table_name = :cpd_cycles
  config.cpd_categories_table_name = :cpd_categories
  config.cpd_activities_table_name = :cpd_activities
  config.cpd_rules_table_name = :cpd_rules

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    cpd: 'application',
    admin: 'admin'
  }

  config.cycle_label = 'year'       # 'cycle', 'season'
  config.credit_label = 'credit'    # 'credit', 'PDH', 'PDU', 'CCC'

  # Notifications Mailer Settings
  #
  # Schedule rake effective_cpd:notify to run every 10 minutes
  # to send out email poll notifications
  #
  config.mailer = {
    layout: 'effective_cpd_mailer_layout',
    default_from: 'no-reply@example.com'
  }

end