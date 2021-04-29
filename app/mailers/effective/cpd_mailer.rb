module Effective
  class CpdMailer < EffectiveCpd.parent_mailer_class
    default from: -> { EffectiveCpd.mailer_sender }
    layout -> { EffectiveCpd.mailer_layout || 'effective_cpd_mailer_layout' }

    # CPD Audit
    def cpd_audit_opened(cpd_audit, opts = {})
      @cpd_audit = cpd_audit
      @assigns = effective_email_templates_cpd_audit_assigns(cpd_audit)

      mail(headers_for(cpd_audit, opts))
    end

    def cpd_audit_conflicted(cpd_audit, opts = {})
      @cpd_audit = cpd_audit
      @assigns = effective_email_templates_cpd_audit_assigns(cpd_audit)

      mail(to: 'admin@blah.com')
    end

    def cpd_audit_conflict_resolved(cpd_audit, opts = {})
      @cpd_audit = cpd_audit
      @assigns = effective_email_templates_cpd_audit_assigns(cpd_audit)

      mail(headers_for(cpd_audit, opts))
    end

    def cpd_audit_closed(cpd_audit, opts = {})
      @cpd_audit = cpd_audit
      @assigns = effective_email_templates_cpd_audit_assigns(cpd_audit)

      mail(headers_for(cpd_audit, opts))
    end

    # CPD Audit Review
    def cpd_audit_review_opened(cpd_audit_review, opts = {})
      @cpd_audit_review = cpd_audit_review
      @assigns = effective_email_templates_cpd_audit_review_assigns(cpd_audit_review)

      mail(headers_for(cpd_audit_review, opts))
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
    def effective_email_templates_cpd_audit_assigns(cpd_audit)
      raise('expected an Effective::CpdAudit') unless cpd_audit.kind_of?(Effective::CpdAudit)

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

    def effective_email_templates_cpd_audit_review_assigns(cpd_audit_review)
      raise('expected an Effective::CpdAuditReview') unless cpd_audit_review.kind_of?(Effective::CpdAuditReview)

      {
        reviewer: {
          name: cpd_audit_review.user.to_s,
          email: cpd_audit_review.user.email
        },
        audit_level: cpd_audit_review.cpd_audit_level.to_s,
        title: cpd_audit_review.to_s,
        url: effective_cpd.cpd_audit_review_url(cpd_audit_review)
      }
    end

  end
end
