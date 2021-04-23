module EffectiveCpdAuditsHelper

  def cpd_audit_conflict_of_interest_collection
    [['Yes, there is a conflict of interest', true], ['No conflict of interest', false]]
  end

  def cpd_audit_exemption_request_collection
    [['Yes, I would like to request an exemption', true], ['No exemption request', false]]
  end

  def cpd_audit_extension_request_collection
    [['Yes, I would like to request an extension', true], ['No extension request', false]]
  end

end
