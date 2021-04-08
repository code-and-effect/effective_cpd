module Effective
  class CpdScorer
    def initialize(user:)
      @cycles = CpdCycle.sorted.all
      @statements = CpdStatement.where(user: user).sorted.all
    end

    def score!
      @statements.each_with_index do |statement, index|
        prev_statement = @statements[index-1] if index > 0

        Array(prev_statement&.cpd_statement_activities).each do |activity|
          if activity.marked_for_destruction? # Cascade this down the line
            statement.cpd_statement_activities.each { |activity| activity.mark_for_destruction if activity.original == activity }
          end

          if can_carry_forward?(activity, statement.cpd_cycle)
            update_or_create_carry_forward_activity(activity, statement)
          else
            delete_carry_forward_activity(activity, statement)
          end
        end

        score_statement(statement)
      end

      save!
    end

    protected

    def save!
      CpdStatement.transaction do
        @statements.each { |statement| statement.save! }; true
      end
    end

    def score_statement(statement)
      # Reset the current carry_forwards and messages
      statement.cpd_statement_activities.each do |activity|
        activity.carry_forward = 0
        activity.reduced_messages.clear
      end

      # This scores and enforces CycleActivity.max_credits_per_cycle
      statement.activities.group_by(&:activity).each do |cycle_activity, statement_activities|
        cycle_rule = cycle_activity.rule_for(statement)
        max_credits_per_cycle = cycle_rule.try(:max_credits_per_cycle) || 999999

        activities.each do |activity|
          next if activity.marked_for_destruction?

          activity.score = cycle_activity.score(activity)
          activity.max_score = activity.score # Hack for Category maximums below

          next if max_credits_per_cycle == nil

          max_credits_per_cycle -= activity.score  # Counting down...

          if max_credits_per_cycle < 0
            activity.carry_forward = [0 - max_credits_per_cycle, activity.score].min
            activity.reduced_messages["activity_#{cycle_activity.id}"] = "You have reached the maximum of #{cycle_rule.try(:max_credits_per_cycle)}/#{statement.cycle.cycle_label} for this type of activity"
            activity.score = [activity.score + max_credits_per_cycle, 0].max
          end
        end
      end

      # This enforced CycleCategory.max_credits_per_cycle
      statement.activities.group_by(&:category).each do |cycle_category, activities|
        cycle_rule = cycle_category.rule_for(statement)
        max_credits_per_cycle = cycle_rule.try(:max_credits_per_cycle) || 999999

        next if max_credits_per_cycle == nil

        activities.each do |activity|
          next if activity.marked_for_destruction?

          max_credits_per_cycle -= activity.score   # We're already scored. Counting down...

          if max_credits_per_cycle < 0
            activity.score = [activity.score + max_credits_per_cycle, 0].max
            activity.carry_forward = activity.max_score - activity.score
            activity.reduced_messages["category_#{cycle_category.id}"] = "You have reached the maximum of #{cycle_rule.try(:max_credits_per_cycle)}/#{statement.cycle.cycle_label} for activities in the #{cycle_category.title} category"
          end
        end
      end

      # This enforces the max_cycles_can_carry_forward logic
      # If an Activity cannot be carried forward another cycle, its carry_forward should be 0
      next_cycle = @cycles[@cycles.index(statement.cycle).to_i+1]

      statement.activities.each do |activity|
        next if (activity.carry_forward == 0 || activity.marked_for_destruction?)

        unless can_carry_forward?(activity, next_cycle)
          activity.carry_forward = 0
          activity.reduced_messages['max_cycles_can_carry_forward'] = "This activity cannot be carried forward any further"
        end
      end

      # Finally set the score from the sum of activitiy scores
      statement.score = statement.activities.map { |activity| activity.marked_for_destruction? ? 0 : activity.score }.sum()
    end

    def can_carry_forward?(activity, to_cycle = nil) # This is a StatementActivity being passed
      return false if (activity.carry_forward == 0 || activity.marked_for_destruction?)

      from_cycle = @cycles.find { |cycle| cycle.id == (activity.original || activity).cpd_statement.cpd_cycle_id }
      max_cycles_can_carry_forward = from_cycle.rule_for(activity).max_cycles_can_carry_forward

      return true if max_cycles_can_carry_forward.blank?

      cycles_carried = (@cycles.index(to_cycle) || @cycles.size) - @cycles.index(from_cycle)
      cycles_carried <= max_cycles_can_carry_forward
    end

    def update_or_create_carry_forward_activity(activity, statement)
      existing = statement.cpd_statement_activities.find { |a| a.original == (activity.original || activity) }
      existing ||= statement.cpd_statement_activities.build()

      existing.assign_attributes(
        cpd_category: activity.cpd_category,
        cpd_activity: activity.cpd_activity,
        amount: activity.amount,
        amount2: activity.amount2,
        description: activity.description
      )

      existing.assign_attributes(carry_over: activity.carry_forward, original: activity.original || activity)
      existing
    end

    def delete_carry_forward_activity(activity, statement)
      existing = statement.cpd_statement_activities.find { |a| a.original == (activity.original || activity) }
      existing&.mark_for_destruction
    end

  end
end
