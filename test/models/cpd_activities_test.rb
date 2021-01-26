require 'test_helper'

class CpdActivitiesTest < ActiveSupport::TestCase
  test 'formula validations' do
    cpd_activity = Effective::CpdActivity.new

    # Valid formula
    cpd_activity.update(formula: '30')
    refute cpd_activity.errors[:formula].present?
    refute cpd_activity.errors[:amount_label].present?
    refute cpd_activity.errors[:amount2_abel].present?

    # Missing amount_label
    cpd_activity.update(formula: 'amount')
    assert cpd_activity.errors[:amount_label].present?

    cpd_activity.update(formula: 'amount2')
    assert cpd_activity.errors[:amount2_label].present?

    cpd_activity.update(formula: 'amount + amount2')
    assert cpd_activity.errors[:amount_label].present?
    assert cpd_activity.errors[:amount2_label].present?

    cpd_activity.update(formula: 'asdf')
    assert cpd_activity.errors[:formula].present?

    cpd_activity.update(formula: '((3)')
    assert cpd_activity.errors[:formula].present?

    cpd_activity.update(formula: '10 / amount')
    assert cpd_activity.errors[:formula].present?
  end

end
