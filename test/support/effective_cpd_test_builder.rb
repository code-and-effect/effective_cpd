module EffectiveCpdTestBuilder
  def create_effective_cpd_cycle!
    build_effective_cpd_cycle.tap { |cpd_cycle| cpd_cycle.save! }
  end

  def build_effective_cpd_cycle
    cpd_cycle = Effective::CpdCycle.new(
      title: 'Cpd Cycle',
      start_at: Time.zone.now,
      end_at: Time.zone.now.end_of_day,
      required_score: nil,
    )

    cpd_cycle.all_steps_content = 'All Steps Content'

    category = build_cpd_category(cpd_cycle, 'Category A')
    build_cpd_activity(category, 'Activity 1')
    build_cpd_activity(category, 'Activity 2')
    build_cpd_activity(category, 'Activity 3')

    category = build_cpd_category(cpd_cycle, 'Category B')
    build_cpd_activity(category, 'Activity 4')
    build_cpd_activity(category, 'Activity 5')
    build_cpd_activity(category, 'Activity 6')

    cpd_cycle
  end

  def build_cpd_category(cpd_cycle, title)
    cpd_category = cpd_cycle.cpd_categories.build(
      title: title,
      body: "#{title} body",
      max_credits_per_cycle: nil
    )
  end

  def build_cpd_activity(cpd_category, title)
    cpd_activity = cpd_category.cpd_activities.build(
      title: title,
      body: "#{title} body",
      formula: 'amount * 10',
      amount_label: 'hours worked',
      amount2_label: nil,
      max_credits_per_cycle: nil,
      max_cycles_can_carry_forward: nil
    )
  end

  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

end
