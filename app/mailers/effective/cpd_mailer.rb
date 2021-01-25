module Effective
  class CpdMailer < ActionMailer::Base
    default from: EffectiveCpd.mailer[:default_from]
    layout EffectiveCpd.mailer[:layout].presence || 'effective_cpd_mailer_layout'

  end
end
