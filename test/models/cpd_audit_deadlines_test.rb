require 'test_helper'

class CpdAuditDeadlinesTest < ActiveSupport::TestCase

  test 'due date is present on new cpd audit' do
    now = Time.zone.now.to_date
    days_10 = EffectiveResources.advance_date(now, business_days: 10)
    days_20 = EffectiveResources.advance_date(now, business_days: 20)
    days_40 = EffectiveResources.advance_date(now, business_days: 40)

    cpd_audit_level = build_effective_cpd_audit_level()
    assert_equal 20, cpd_audit_level.days_to_submit

    cpd_audit = build_effective_cpd_audit(cpd_audit_level: cpd_audit_level)
    cpd_audit.save!

    # Cpd Audit due dates
    assert_equal days_10, cpd_audit.deadline_to_conflict_of_interest
    assert_equal days_10, cpd_audit.deadline_to_exemption
    assert_equal days_10, cpd_audit.deadline_to_extension
    assert_equal days_20, cpd_audit.deadline_to_submit
    assert_equal days_20, cpd_audit.due_date

    # Cpd Audit Review due dates
    cpd_audit.cpd_audit_reviews.each do |cpd_audit_review|
      assert_equal days_10, cpd_audit_review.deadline_to_conflict_of_interest
      assert_equal days_40, cpd_audit_review.deadline_to_review
      assert_equal days_40, cpd_audit_review.due_date
    end
  end

  test 'due date is blank on new cpd audit when level blank' do
    cpd_audit_level = build_effective_cpd_audit_level()
    cpd_audit_level.update!(days_to_submit: nil)

    cpd_audit = build_effective_cpd_audit(cpd_audit_level: cpd_audit_level)
    cpd_audit.save!
    assert cpd_audit.due_date.nil?
  end

  test 'granting an extension updates the due date' do
    now = Time.zone.now.to_date

    days_10 = EffectiveResources.advance_date(now, business_days: 10)
    days_20 = EffectiveResources.advance_date(now, business_days: 20)
    days_30 = EffectiveResources.advance_date(now, business_days: 30)
    days_40 = EffectiveResources.advance_date(now, business_days: 40)
    days_50 = EffectiveResources.advance_date(now, business_days: 50)
    days_70 = EffectiveResources.advance_date(now, business_days: 70)

    cpd_audit_level = build_effective_cpd_audit_level()
    assert_equal 20, cpd_audit_level.days_to_submit

    cpd_audit = build_effective_cpd_audit(cpd_audit_level: cpd_audit_level)
    cpd_audit.save!

    # Make the request
    cpd_audit.assign_attributes(extension_request: true, extension_request_date: days_30, extension_request_reason: 'Test')
    cpd_audit.extension!

    assert_equal days_20, cpd_audit.due_date

    cpd_audit.cpd_audit_reviews.each do |cpd_audit_review|
      assert_equal days_40, cpd_audit_review.deadline_to_review
      assert_equal days_40, cpd_audit_review.due_date
    end

    # Grant the request
    cpd_audit.grant_extension!
    assert_equal days_50, cpd_audit.due_date

    cpd_audit.cpd_audit_reviews.each do |cpd_audit_review|
      assert_equal days_70, cpd_audit_review.deadline_to_review
      assert_equal days_70, cpd_audit_review.due_date
    end
  end

end
