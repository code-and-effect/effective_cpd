module Admin
  class EffectiveCpdAuditsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :available, label: 'In Progress'
      scope :completed
      scope :waiting_on_admin
      scope :waiting_on_auditee
      scope :waiting_on_reviewers
    end

    datatable do
      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :token, visible: false

      col :cpd_audit_level, label: 'Audit Level'

      col :user, search: :string, label: 'Auditee'

      col(:cpd_audit_reviews, label: 'Auditor Reviewers', search: :string) do |cpd_audit|
        cpd_audit.cpd_audit_reviews.map(&:user).map do |user|
          content_tag(:div, class: 'col-resource_item') do
            if view.respond_to?(:edit_admin_user_path)
              link_to(user.to_s, edit_admin_user_path(user))
            else
              user.to_s
            end
          end
        end.join.html_safe
      end

      col :notification_date, label: 'Date of Notification'
      col :extension_date, label: 'Approved Extension Date', visible: false
      col :due_date

      col :status
      col :determination

      col(:auditee_cpd_statements, label: 'Auditee Statements') do |cpd_audit|
        cpd_audit.user.cpd_statements.map do |cpd_statement|
          content_tag(:div, class: 'col-resource_item') do
            link_to(cpd_statement.to_s, effective_cpd.admin_cpd_statement_path(cpd_statement))
          end
        end.join.html_safe
      end

      col :conflict_of_interest, visible: false
      col :conflict_of_interest_reason, visible: false

      col :exemption_request, visible: false
      col :exemption_request_reason, visible: false

      col :extension_request, visible: false
      col :extension_request_date, visible: false
      col :extension_request_reason, visible: false

      actions_col
    end

    collection do
      Effective::CpdAudit.all.deep
    end
  end
end
