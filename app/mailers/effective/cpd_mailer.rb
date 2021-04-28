module Effective
  class CpdMailer < EffectiveCpd.parent_mailer_class
    default from: -> { EffectiveCpd.mailer_sender }
    layout -> { EffectiveCpd.mailer_layout || 'effective_cpd_mailer_layout' }

    def cpd_audit_closed(cpd_audit, opts = {})
      @assigns = effective_email_templates_assigns(cpd_audit)
      headers = headers_for(cpd_audit, opts)

      mail(headers)
    end

    protected

    def headers_for(resource, opts = {})
      if resource.respond_to?(:log_changes_datatable)
        opts.merge(to: resource.user.email, log: resource)
      else
        opts.merge(to: resource.user.email)
      end
    end

    # Only relevant if the effective_email_templates gem is present
    def effective_email_templates_assigns(cpd_audit)
      raise('expected an Effective::CpdAudit') unless cpd_audit.kind_of?(Effective::CpdAudit)

      @cpd_audit = cpd_audit

      {
        auditee: {
          name: cpd_audit.user.to_s,
          email: cpd_audit.user.email
        },
        audit_level: cpd_audit.cpd_audit_level.to_s,
        title: cpd_audit.to_s,
        determination: cpd_audit.determination,
        url: effective_cpd.cpd_audit_url(cpd_audit)
      }
    end

  end
end
