require 'test_helper'

class CpdAuditTest < ActiveSupport::TestCase
  def email_payload
    {
      email_form_action: true,
      email_form_from: "registrar@example.com",
      email_form_subject: "Audit closed",
      email_form_body: "Audit all done"
    }
  end

  test 'create a valid audit' do
    cpd_audit = build_effective_cpd_audit()
    assert cpd_audit.valid?
    assert_equal 2, cpd_audit.cpd_audit_reviews.length

    assert_email(count: 3) { cpd_audit.save! }
  end

  test 'valid audit with skip one email content' do
    cpd_audit = build_effective_cpd_audit()
    assert cpd_audit.valid?
    assert_equal 2, cpd_audit.cpd_audit_reviews.length

    cpd_audit.assign_attributes(email_payload)
    cpd_audit.cpd_audit_reviews.first.assign_attributes(email_payload)
    cpd_audit.cpd_audit_reviews.last.assign_attributes(email_form_skip: true)

    assert_email(count: 2) { cpd_audit.save! }
  end

  test 'submit an audit' do
    cpd_audit = create_effective_cpd_audit!()
    assert_email(count: 3) { cpd_audit.submit! }
  end

  test 'close action without email' do
    cpd_audit = create_effective_cpd_audit!()

    cpd_audit.determination = cpd_audit.cpd_audit_level.determinations.first

    assert_email { cpd_audit.close! }
  end

  test 'close action with email content' do
    cpd_audit = create_effective_cpd_audit!()

    cpd_audit.determination = cpd_audit.cpd_audit_level.determinations.first
    cpd_audit.assign_attributes(email_payload)

    assert_email { cpd_audit.close! }

    message = ActionMailer::Base.deliveries.last

    assert_equal [cpd_audit.user.email], message.to
    assert_equal ["registrar@example.com"], message.from
    assert_equal "Audit closed", message.subject
    assert_equal "Audit all done", message.body.to_s
  end

end
