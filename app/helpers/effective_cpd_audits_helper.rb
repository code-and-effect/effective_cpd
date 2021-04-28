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

  def cpd_audit_summary_text(cpd_audit)
    case cpd_audit.status
    when 'opened'
      "The audit has been opened. The auditee and audit reviewers have been notified. Waiting for the auditee to submit their audit questionnaire."
    when 'started'
      "The auditee has begun their audit questionnaire. Waiting for the auditee to submit their audit questionnaire."
    when 'conflicted'
      "The auditee has declared a conflict of interest. Waiting for a new reviewer to be assigned or otherwise resolved."
    when 'conflicted_resolved'
      "The auditee had declared a conflict of interest. This has been resolved. Waiting for the auditee to submit their audit questionnaire."
    when 'exemption_requested'
      "The auditee has requested an exemption. Waiting for request to be granted or denied."
    when 'exemption_granted'
      "The exemption request has been granted. This audit may now be closed."
    when 'exemption_denied'
      "The exemption request has been denied. The audit will continue. Waiting for the auditee to submit their audit questionnaire."
    when 'extension_requested'
      "The auditee has requested an extension. Waiting for request to be granted or denied."
    when 'extension_granted'
      "The extension request has been granted. There is a new deadline. Waiting for the auditee to submit their audit questionnaire."
    when 'extension_denied'
      "The extension request has been denied. The deadline remains. Waiting for the auditee to submit their audit questionnaire."
    when 'submitted'
      "The auditee has submitted their audit questionnaire. Waiting on review."
    when 'reviewed'
      "The audit has been reviewed and is ready for the final determination to be made."
    when 'closed'
      "This audit has been closed. A final determination was made. All parties have been notified. The audit is all done."
    else
      raise("unexpected cpd audit status: #{cpd_audit.status}")
    end
  end

end
