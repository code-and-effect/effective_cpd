require 'test_helper'

class CpdScorerTest < ActiveSupport::TestCase
  test 'complete statement points amount 10' do
    cpd_statement = create_scoreable_cpd_statement!(amount: 10, amount2: 10)

    assert_equal 7, cpd_statement.cpd_statement_activities.map(&:cpd_category_id).uniq.length
    assert_equal 25, cpd_statement.cpd_statement_activities.map(&:cpd_activity_id).uniq.length

    assert_equal 330, cpd_statement.cpd_statement_activities.map(&:score).sum
    assert_equal 330, cpd_statement.score
  end

  test 'complete statement points amount 1' do
    cpd_statement = create_scoreable_cpd_statement!(amount: 1, amount2: 1)

    assert_equal 7, cpd_statement.cpd_statement_activities.map(&:cpd_category_id).uniq.length
    assert_equal 25, cpd_statement.cpd_statement_activities.map(&:cpd_activity_id).uniq.length

    assert_equal 67, cpd_statement.cpd_statement_activities.map(&:score).sum
    assert_equal 67, cpd_statement.score
  end

  test 'roll forward amount 10' do
    user = create_user!

    # First Statement
    first = create_scoreable_cpd_statement!(user: user)
    assert_equal 330, first.score

    assert_equal 25, first.cpd_statement_activities.length
    assert first.cpd_statement_activities.all? { |a| a.carry_over.nil? }
    assert first.cpd_statement_activities.all? { |a| a.original.nil? }

    assert_equal 410, first.cpd_statement_activities.sum(&:carry_forward)
    assert_equal 330, first.cpd_statement_activities.sum(&:score)
    assert_equal [20, 20, 20, 15, 15, 30, 210], first.score_per_category.values
    assert_equal 410, first.carry_forward

    # Second Statement
    second = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 80, second.score

    assert_equal 13, second.cpd_statement_activities.length
    assert second.cpd_statement_activities.all? { |a| a.original.present? && a.original.cpd_statement.cpd_cycle == first.cpd_cycle }
    assert second.cpd_statement_activities.all? { |a| a.carry_over.present? }

    assert_equal 410, second.cpd_statement_activities.sum(&:carry_over)
    assert_equal 80, second.cpd_statement_activities.sum(&:score)
    assert_equal [20, 15, 15, 30], second.score_per_category.values
    assert_equal 330, second.cpd_statement_activities.sum(&:carry_forward)

    # Third Statement
    third = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 45, third.score

    assert_equal 7, third.cpd_statement_activities.length
    assert third.cpd_statement_activities.all? { |a| a.original.present? && a.original.cpd_statement.cpd_cycle == first.cpd_cycle }
    assert third.cpd_statement_activities.all? { |a| a.carry_over.present? }

    assert_equal 330, third.cpd_statement_activities.sum(&:carry_over)
    assert_equal 45, third.cpd_statement_activities.sum(&:score)
    assert_equal [15, 30], third.score_per_category.values
    assert_equal 0, third.cpd_statement_activities.sum(&:carry_forward)

    # Fourth Statement
    fourth = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 0, fourth.score
    assert_equal 0, fourth.cpd_statement_activities.length
  end

  test 'roll forward zero cycles' do
    user = create_user!

    # First Statement
    Effective::CpdRule.update_all(max_cycles_can_carry_forward: 0)
    first = create_scoreable_cpd_statement!(user: user, amount: 1, amount2: 1)
    assert_equal 67, first.score

    assert_equal 25, first.cpd_statement_activities.length
    assert first.cpd_statement_activities.all? { |a| a.carry_over.nil? }
    assert first.cpd_statement_activities.all? { |a| a.original.nil? }

    assert_equal 0, first.cpd_statement_activities.sum(&:carry_forward)
    assert_equal 67, first.cpd_statement_activities.sum(&:score)
    assert_equal [2, 4, 2, 5, 3, 30, 21], first.score_per_category.values
    assert_equal 0, first.carry_forward
  end

  test 'roll forward amount 1' do
    user = create_user!

    # First Statement
    first = create_scoreable_cpd_statement!(user: user, amount: 1, amount2: 1)
    assert_equal 67, first.score

    assert_equal 25, first.cpd_statement_activities.length
    assert first.cpd_statement_activities.all? { |a| a.carry_over.nil? }
    assert first.cpd_statement_activities.all? { |a| a.original.nil? }

    assert_equal 7, first.cpd_statement_activities.sum(&:carry_forward)
    assert_equal 67, first.cpd_statement_activities.sum(&:score)
    assert_equal [2, 4, 2, 5, 3, 30, 21], first.score_per_category.values
    assert_equal 7, first.carry_forward

    # Second Statement
    second = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 7, second.score

    assert_equal 2, second.cpd_statement_activities.length
    assert second.cpd_statement_activities.all? { |a| a.original.present? && a.original.cpd_statement.cpd_cycle == first.cpd_cycle }
    assert second.cpd_statement_activities.all? { |a| a.carry_over.present? }

    assert_equal 7, second.cpd_statement_activities.sum(&:carry_over)
    assert_equal 7, second.cpd_statement_activities.sum(&:score)
    assert_equal [7], second.score_per_category.values
    assert_equal 0, second.cpd_statement_activities.sum(&:carry_forward)

    # Third Statement
    third = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 0, third.score
    assert_equal 0, third.cpd_statement_activities.length
  end

  test 'cascading delete' do
    user = create_user!

    # First Statement
    first = create_scoreable_cpd_statement!(user: user, amount: 1, amount2: 1)
    second = create_scoreable_cpd_statement!(user: user, continue: true)

    assert_equal 67, first.score
    assert_equal 7, second.score

    assert_equal 25, first.cpd_statement_activities.length
    assert_equal 2, second.cpd_statement_activities.length

    carried = second.cpd_statement_activities.find { |csa| csa.is_carry_over? }.original
    carried.destroy!

    Effective::CpdScorer.new(user: user).score!

    first.reload
    second.reload

    assert_equal 24, first.cpd_statement_activities.length
    assert_equal 0, second.cpd_statement_activities.length

    assert_equal 64, first.score
    assert_equal 0, second.score
  end

end
