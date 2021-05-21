module Effective
  class CpdSpecialRuleMate < ActiveRecord::Base
    belongs_to :cpd_rule
    belongs_to :cpd_special_rule
  end
end
