require 'test_helper'

class CpdSpecialRulesTest < ActiveSupport::TestCase
  test 'cumulative max credits' do
    cpd_statement = create_effective_cpd_statement!
    cpd_categories = Effective::CpdCategory.all.first(2)
    cpd_cycle = cpd_statement.cpd_cycle

    # Create a normal statement with just 2 activities that add upto 20 per category for 40 each
    cpd_categories.each do |category|
      activity = category.cpd_activities.first

      cpd_statement.cpd_statement_activities.create!(
        cpd_category: category,
        cpd_activity: activity,
        amount: (15 if activity.amount_label.present?),
        amount2: (15 if activity.amount2_label.present?),
        description: 'test'
      )
    end

    Effective::CpdScorer.new(user: cpd_statement.user).score!
    assert_equal 30, cpd_statement.reload.score

    # Now create the special rule
    special_rule = Effective::CpdSpecialRule.create!(
      cpd_cycle: cpd_cycle,
      category: 'cumulative max credits',
      max_credits_per_cycle: 20
    )

    # Add all the categories into the rule
    cpd_categories.each { |cpd_category| special_rule.cpd_rules << cpd_cycle.rule_for(cpd_category) }

    # Rescore the statement
    Effective::CpdScorer.new(user: cpd_statement.user).score!

    assert_equal 20, cpd_statement.reload.score
    assert_equal 15, cpd_statement.cpd_statement_activities.first.score

    activity2 = cpd_statement.cpd_statement_activities.last
    assert_equal 5, activity2.score
    assert_equal 10, activity2.carry_forward
    assert activity2.reduced_messages.values.first.to_s.start_with?('You have reached the cumulative maximum of 20/year')
  end

end
