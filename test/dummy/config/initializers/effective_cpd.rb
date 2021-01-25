EffectiveCpd.setup do |config|
  config.cpd_cycles_table_name = :cpd_cycles
  config.cpd_categories_table_name = :cpd_categories
  config.cpd_activities_table_name = :cpd_activities
  config.cpd_rules_table_name = :cpd_rules

  # Authorization Method
  #
  # This method is called by all controller actions with the appropriate action and resource
  # If it raises an exception or returns false, an Effective::AccessDenied Error will be raised
  #
  # Use via Proc:
  # Proc.new { |controller, action, resource| authorize!(action, resource) }       # CanCan
  # Proc.new { |controller, action, resource| can?(action, resource) }             # CanCan with skip_authorization_check
  # Proc.new { |controller, action, resource| authorize "#{action}?", resource }   # Pundit
  # Proc.new { |controller, action, resource| current_user.is?(:admin) }           # Custom logic
  #
  # Use via Boolean:
  # config.authorization_method = true  # Always authorized
  # config.authorization_method = false # Always unauthorized
  #
  # Use via Method (probably in your application_controller.rb):
  # config.authorization_method = :my_authorization_method
  # def my_authorization_method(resource, action)
  #   true
  # end
  config.authorization_method = Proc.new { |controller, action, resource| authorize!(action, resource) }

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    cpd: 'application',
    admin: 'admin'
  }

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
