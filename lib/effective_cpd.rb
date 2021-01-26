require 'effective_resources'
require 'effective_datatables'
require 'effective_cpd/engine'
require 'effective_cpd/version'

module EffectiveCpd
  mattr_accessor :cpd_cycles_table_name
  mattr_accessor :cpd_categories_table_name
  mattr_accessor :cpd_activities_table_name

  mattr_accessor :cycle_label
  mattr_accessor :credit_label

  mattr_accessor :authorization_method
  mattr_accessor :layout

  # Hashes of configs
  mattr_accessor :mailer

  def self.setup
    yield self
  end

  def self.authorized?(controller, action, resource)
    @_exceptions ||= [Effective::AccessDenied, (CanCan::AccessDenied if defined?(CanCan)), (Pundit::NotAuthorizedError if defined?(Pundit))].compact

    return !!authorization_method unless authorization_method.respond_to?(:call)
    controller = controller.controller if controller.respond_to?(:controller)

    begin
      !!(controller || self).instance_exec((controller || self), action, resource, &authorization_method)
    rescue *@_exceptions
      false
    end
  end

  def self.authorize!(controller, action, resource)
    raise Effective::AccessDenied.new('Access Denied', action, resource) unless authorized?(controller, action, resource)
  end

end
