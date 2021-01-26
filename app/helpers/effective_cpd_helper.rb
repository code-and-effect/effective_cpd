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

end
