require 'test_helper'

class CpdRulesTest < ActiveSupport::TestCase
  test 'invalid formulas ' do
    cpd_rule = Effective::CpdRule.new

    cpd_rule.update(formula: '((3)')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: '10 / amount')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'asdf')
    assert cpd_rule.errors[:formula].present?
  end

  test 'valid formulas' do
    cpd_rule = Effective::CpdRule.new

    cpd_rule.update(formula: '30')
    refute cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount')
    refute cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: '10 * amount')
    refute cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount + amount2')
    refute cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount * amount2')
    refute cpd_rule.errors[:formula].present?
  end

  test 'amount_label formula validation' do
    cpd_activity = Effective::CpdActivity.new(amount_label: 'unit', amount2_label: nil)
    cpd_rule = Effective::CpdRule.new(ruleable: cpd_activity)

    # Valid
    cpd_rule.update(formula: 'amount')
    refute cpd_rule.errors[:formula].present?

    # Invalid
    cpd_rule.update(formula: 'amount2')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: '10')
    assert cpd_rule.errors[:formula].present?
  end

  test 'amount2_label formula validation' do
    cpd_activity = Effective::CpdActivity.new(amount_label: nil, amount2_label: 'unit')
    cpd_rule = Effective::CpdRule.new(ruleable: cpd_activity)

    # Valid
    cpd_rule.update(formula: 'amount2')
    refute cpd_rule.errors[:formula].present?

    # Invalid
    cpd_rule.update(formula: 'amount')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: '10')
    assert cpd_rule.errors[:formula].present?
  end

  test 'amount_label and amount2_label validation' do
    cpd_activity = Effective::CpdActivity.new(amount_label: 'unit', amount2_label: 'unit')
    cpd_rule = Effective::CpdRule.new(ruleable: cpd_activity)

    # Valid
    cpd_rule.update(formula: 'amount + amount2')
    refute cpd_rule.errors[:formula].present?

    # Invalid
    cpd_rule.update(formula: 'amount')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount2')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: '10')
    assert cpd_rule.errors[:formula].present?
  end

  test 'no amount labels formula validation' do
    cpd_activity = Effective::CpdActivity.new(amount_label: nil, amount2_label: nil)
    cpd_rule = Effective::CpdRule.new(ruleable: cpd_activity)

    # Valid
    cpd_rule.update(formula: '100')
    refute cpd_rule.errors[:formula].present?

    # Invalid
    cpd_rule.update(formula: 'amount')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount2')
    assert cpd_rule.errors[:formula].present?

    cpd_rule.update(formula: 'amount + amount2')
    assert cpd_rule.errors[:formula].present?
  end

end
