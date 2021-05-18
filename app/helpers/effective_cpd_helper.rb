module EffectiveCpdHelper

  def cpd_cycle_label
    (EffectiveCpd.cycle_label || '').to_s.html_safe
  end

  def cpd_cycles_label
    (EffectiveCpd.cycle_label || '').to_s.pluralize.html_safe
  end

  def cpd_credit_label
    (EffectiveCpd.credit_label || '').to_s.html_safe
  end

  def cpd_credits_label
    (EffectiveCpd.credit_label || '').to_s.pluralize.html_safe
  end

  def cpd_rule_formula_hint(cpd_activity)
    raise('expected a CPDActivity') unless cpd_activity.kind_of?(Effective::CpdActivity)

    if cpd_activity.amount_label.present? && cpd_activity.amount2_label.present?
      "must include 'amount' and 'amount2'. Something like (amount + (amount2 * 10))"
    elsif cpd_activity.amount_label.present?
      "must include 'amount'. Something like (10 * amount)"
    elsif cpd_activity.amount2_label.present?
      "must include 'amount2'. Something like (10 * amount2)"
    else
      "must be a number and may not include 'amount'. Something like 10"
    end
  end

  def cpd_statement_submit_label(cpd_statement)
    label = "Yes, I understand I will not be able to submit more #{cpd_credits_label} or modify any of my activities for this #{cpd_cycle_label}, once I submit."

    if (end_at = cpd_statement.cpd_cycle.end_at).present?
      label += " The last date to submit this form is #{end_at.strftime("%B %d, %Y")}."
    end

    label
  end

  def effective_cpd_categories
    @effective_cpd_categories ||= Effective::CpdCategory.deep.sorted
  end

end
