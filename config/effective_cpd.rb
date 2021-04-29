EffectiveCpd.setup do |config|
  config.cpd_categories_table_name = :cpd_categories
  config.cpd_activities_table_name = :cpd_activities

  config.cpd_cycles_table_name = :cpd_cycles
  config.cpd_rules_table_name = :cpd_rules

  config.cpd_statements_table_name = :cpd_statements
  config.cpd_statement_activities_table_name = :cpd_statement_activities

  config.cpd_audit_levels_table_name = :cpd_audit_levels
  config.cpd_audit_level_sections_table_name = :cpd_audit_level_sections
  config.cpd_audit_level_questions_table_name = :cpd_audit_level_questions
  config.cpd_audit_level_question_options_table_name = :cpd_audit_level_question_options

  config.cpd_audits_table_name = :cpd_audits
  config.cpd_audit_responses_table_name = :cpd_audit_level_responses
  config.cpd_audit_response_options_table_name = :cpd_audit_level_response_options

  config.cpd_audit_reviews_table_name = :cpd_audit_reviews
  config.cpd_audit_review_items_table_name = :cpd_audit_review_items

  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    cpd: 'application',
    admin: 'admin'
  }

  # Program label settings
  config.cycle_label = 'year'       # 'cycle', 'season'
  config.credit_label = 'credit'    # 'credit', 'PDH', 'PDU', 'CCC'

  # Auditee Scope Collection
  #
  # When creating a new audit, these are used to select the auditee
  # The User model must respond to these
  config.auditee_user_scope = :all

  # Audit Reviewer Scope Collection
  config.audit_reviewer_user_scope = :all

  # Mailer Configuration
  # Configure the class responsible to send e-mails.
  # config.mailer = 'Effective::CpdMailer'

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # Default deliver method
  # config.deliver_method = :deliver_later

  # Default layout
  config.mailer_layout = 'effective_cpd_mailer_layout'

  # Default From
  config.mailer_sender = "no-reply@example.com"

  # Send Admin correspondence To
  config.mailer_admin = "admin@example.com"

  # Will work with effective_email_templates gem:
  # - The audit and audit review email content will be preopulated based off the template
  # - Uses an EmailTemplatesMailer mailer instead of ActionMailer::Base for default parent_mailer
  config.use_effective_email_templates = false
end
