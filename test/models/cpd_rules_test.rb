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

end
