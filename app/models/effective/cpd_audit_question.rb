module Effective
  class CpdAuditQuestion < ActiveRecord::Base
    belongs_to :cpd_audit_section

    has_many :cpd_audit_question_options, -> { CpdAuditQuestionOption.sorted }, inverse_of: :cpd_audit_question, dependent: :delete_all
    accepts_nested_attributes_for :cpd_audit_question_options, reject_if: :all_blank, allow_destroy: true

    has_rich_text :body
    log_changes(to: :cpd_audit_section) if respond_to?(:log_changes)

    CATEGORIES = [
      'Choose one',   # Radios
      'Select all that apply', # Checks
      'Select up to 1',
      'Select up to 2',
      'Select up to 3',
      'Select up to 4',
      'Select up to 5',
      'Date',         # Date Field
      'Email',        # Email Field
      'Number',       # Numeric Field
      'Long Answer',  # Text Area
      'Short Answer', # Text Field
      'Upload File'   # File field
    ]

    WITH_OPTIONS_CATEGORIES = [
      'Choose one',   # Radios
      'Select all that apply', # Checks
      'Select up to 1',
      'Select up to 2',
      'Select up to 3',
      'Select up to 4',
      'Select up to 5'
    ]

    effective_resource do
      title     :text
      category      :string
      required      :boolean

      position  :integer

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_audit_section, :cpd_audit_question_options) }
    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_audit_section.present? }) do
      self.position ||= (cpd_audit_section.cpd_audit_questions.map(&:position).compact.max || -1) + 1
    end

    validates :title, presence: true
    validates :category, presence: true, inclusion: { in: CATEGORIES }
    validates :position, presence: true
    validates :cpd_audit_question_options, presence: true, if: -> { audit_question_option? }

    # Create choose_one? and select_all_that_apply? methods for each category
    CATEGORIES.each do |category|
      define_method(category.parameterize.underscore + '?') { self.category == category }
    end

    def question_option?
      WITH_OPTIONS_CATEGORIES.include?(category)
    end

    def category_partial
      category.to_s.parameterize.underscore
    end

    def to_s
      title.presence || 'audit question'
    end

  end
end
