require 'effective_resources'
require 'effective_datatables'
require 'effective_cpd/engine'
require 'effective_cpd/version'

module EffectiveCpd

  def self.config_keys
    [
      :cpd_cycles_table_name, :cpd_categories_table_name, :cpd_activities_table_name, :cpd_rules_table_name,
      :cpd_audit_levels_table_name, :cpd_audit_level_sections_table_name, :cpd_audit_level_questions_table_name, :cpd_audit_level_question_options_table_name,
      :cpd_statement_activities_table_name, :cpd_statements_table_name,
      :cycle_label, :credit_label, :layout,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :use_effective_email_templates
    ]
  end

  include EffectiveGem

  def self.mailer_class
    return mailer.constantize if mailer.present?
    Effective::CpdMailer
  end

  def self.parent_mailer_class
    return parent_mailer.constantize if parent_mailer.present?

    if use_effective_email_templates
      require 'effective_email_templates'
      Effective::EmailTemplatesMailer
    else
      ActionMailer::Base
    end
  end

  def self.send_email(email, *args)
    raise('expected args to be an Array') unless args.kind_of?(Array)

    if defined?(Tenant)
      tenant = Tenant.current || raise('expected a current tenant')
      args << { tenant: tenant }
    end

    deliver_method = EffectiveCpd.deliver_method || EffectiveResources.deliver_method

    begin
      EffectiveCpd.mailer_class.send(email, *args).send(deliver_method)
    rescue => e
      raise if Rails.env.development? || Rails.env.test?
    end
  end

end
