module EffectiveCpdTestBuilder
  def create_effective_cpd_audit!
    build_effective_cpd_audit.tap { |cpd_audit| cpd_audit.save! }
  end

  def build_effective_cpd_audit(cpd_audit_level: nil, user: nil, reviewers: nil)
    cpd_audit_level ||= create_effective_cpd_audit_level!
    user ||= create_user!
    reviewers ||= [create_user!, create_user!]

    cpd_audit = Effective::CpdAudit.new(
      cpd_audit_level: cpd_audit_level,
      user: user,
    )

    reviewers.each do |reviewer|
      cpd_audit.cpd_audit_reviews.build(user: reviewer)
    end

    cpd_audit
  end

  def create_effective_cpd_audit_level!
    build_effective_cpd_audit_level.tap { |cpd_audit_level| cpd_audit_level.save! }
  end

  def build_effective_cpd_audit_level
    cpd_audit_level = Effective::CpdAuditLevel.new(
      title: 'Audit Level',
      determinations: ['Compliant', 'Conditional', 'Refer to Investigations Committee'],
      recommendations: ['Accepted', 'Rejected'],
      days_to_submit: 20,
      days_to_review: 20,

      conflict_of_interest: true,
      can_request_exemption: true,
      can_request_extension: true,

      days_to_declare_conflict: 10,
      days_to_request_exemption: 10,
      days_to_request_extension: 10
    )

    section = cpd_audit_level.cpd_audit_level_sections.build(title: 'Section A')
    section.cpd_audit_level_questions.build(title: 'Question One', category: 'Short Answer')
    section.cpd_audit_level_questions.build(title: 'Question Two', category: 'Long Answer')

    section = cpd_audit_level.cpd_audit_level_sections.build(title: 'Section B')
    section.cpd_audit_level_questions.build(title: 'Question Three', category: 'Short Answer')
    section.cpd_audit_level_questions.build(title: 'Question Four', category: 'Long Answer')

    cpd_audit_level
  end

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
    cpd_cycle
  end

  def create_effective_cpd_statement!(cpd_cycle: nil, user: nil)
    build_effective_cpd_statement(cpd_cycle: cpd_cycle, user: user).tap { |cpd_statement| cpd_statement.save! }
  end

  def build_effective_cpd_statement(cpd_cycle: nil, user: nil)
    cpd_cycle ||= create_effective_cpd_cycle!
    user ||= create_user!

    cpd_statement = Effective::CpdStatement.new(
      cpd_cycle: cpd_cycle,
      user: user
    )
  end

  # Create a StatementActivity for each activity.
  def create_scoreable_cpd_statement!(cpd_cycle: nil, user: nil, amount: 10, amount2: 10, continue: false)
    cpd_statement = create_effective_cpd_statement!(cpd_cycle: cpd_cycle, user: user)

    unless continue
      Effective::CpdCategory.sorted.all.each do |category|
        category.cpd_activities.each do |activity|
          csa = cpd_statement.cpd_statement_activities.create!(
            cpd_category: category,
            cpd_activity: activity,
            amount: (amount if activity.amount_label.present?),
            amount2: (amount2 if activity.amount2_label.present?),
            description: 'test'
          )
        end
      end
    end

    Effective::CpdScorer.new(user: cpd_statement.user).score!
    cpd_statement.reload

    cpd_statement
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
