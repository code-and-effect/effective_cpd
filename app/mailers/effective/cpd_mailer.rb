module Effective
  class CpdMailer < EffectiveCpd.parent_mailer_class
    default from: -> { EffectiveCpd.mailer_sender }
    layout -> { EffectiveCpd.mailer_layout || 'effective_cpd_mailer_layout' }

    # CPD Audit
    def cpd_audit_opened(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_conflicted(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_conflict_resolved(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_exemption_request(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_exemption_denied(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_exemption_granted(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_extension_request(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_extension_denied(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_extension_granted(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_submitted(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_reviewed(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit, opts))
    end

    def cpd_audit_closed(cpd_audit, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit)
      @assigns.merge!(url: effective_cpd.cpd_audit_url(cpd_audit))

      mail(to: cpd_audit.user.email, **headers_for(cpd_audit, opts))
    end

    # CPD Audit Review
    def cpd_audit_review_opened(cpd_audit_review, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit_review)
      @assigns.merge!(url: effective_cpd.cpd_audit_review_url(cpd_audit_review))

      mail(to: cpd_audit_review.user.email, **headers_for(cpd_audit_review, opts))
    end

    def cpd_audit_review_ready(cpd_audit_review, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit_review)
      @assigns.merge!(url: effective_cpd.cpd_audit_review_url(cpd_audit_review))

      mail(to: cpd_audit_review.user.email, **headers_for(cpd_audit_review, opts))
    end

    def cpd_audit_review_submitted(cpd_audit_review, opts = {})
      @assigns = effective_cpd_email_assigns(cpd_audit_review)
      @assigns.merge!(url: effective_cpd.edit_admin_cpd_audit_url(cpd_audit_review.cpd_audit))

      mail(to: EffectiveCpd.mailer_admin, **headers_for(cpd_audit_review, opts))
    end

    protected

    def headers_for(resource, opts = {})
      resource.respond_to?(:log_changes_datatable) ? opts.merge(log: resource) : opts
    end

    def effective_cpd_email_assigns(resource)
      unless resource.kind_of?(Effective::CpdAudit) || resource.kind_of?(Effective::CpdAuditReview)
        raise('expected an Effective::CpdAudit or Effective::CpdAuditReview')
      end

      @cpd_audit = (resource.kind_of?(Effective::CpdAudit) ? resource : resource.cpd_audit)
      @cpd_audit_review = (resource if resource.kind_of?(Effective::CpdAuditReview))

      @auditee = @cpd_audit.user
      @reviewer = @cpd_audit_review.user if @cpd_audit_review.present?

      audit_assigns = {
        audit: {
          title: @cpd_audit.to_s,
          level: @cpd_audit.cpd_audit_level.to_s,
          determination: @cpd_audit.determination.to_s
        },
        auditee: {
          name: @auditee.to_s,
          email: @auditee.email
        }
      }

      review_assigns = if @cpd_audit_review.present?
        {
          review: {
            title: @cpd_audit_review.to_s,
            recommendation: @cpd_audit_review.recommendation.to_s
          },
          reviewer: {
            name: @reviewer.to_s,
            email: @reviewer.email
          }
        }
      end

      audit_assigns.merge(review_assigns || {})
    end

  end
end
