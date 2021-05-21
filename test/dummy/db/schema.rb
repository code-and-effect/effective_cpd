# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 5) do

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cpd_activities", force: :cascade do |t|
    t.bigint "cpd_category_id"
    t.string "title"
    t.integer "position"
    t.string "amount_label"
    t.string "amount2_label"
    t.boolean "requires_upload_file", default: false
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_category_id"], name: "index_cpd_activities_on_cpd_category_id"
  end

  create_table "cpd_audit_level_question_options", force: :cascade do |t|
    t.bigint "cpd_audit_level_question_id"
    t.text "title"
    t.integer "position"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "cpd_audit_level_questions", force: :cascade do |t|
    t.bigint "cpd_audit_level_id"
    t.bigint "cpd_audit_level_section_id"
    t.text "title"
    t.string "category"
    t.boolean "required", default: true
    t.integer "position"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_level_id"], name: "index_cpd_audit_level_questions_on_cpd_audit_level_id"
    t.index ["cpd_audit_level_section_id"], name: "index_cpd_audit_level_questions_on_cpd_audit_level_section_id"
  end

  create_table "cpd_audit_level_response_options", force: :cascade do |t|
    t.bigint "cpd_audit_response_id"
    t.bigint "cpd_audit_level_question_option_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_response_id"], name: "index_cpd_audit_level_response_options_on_cpd_audit_response_id"
  end

  create_table "cpd_audit_level_responses", force: :cascade do |t|
    t.bigint "cpd_audit_id"
    t.bigint "cpd_audit_level_question_id"
    t.bigint "cpd_audit_level_section_id"
    t.date "date"
    t.string "email"
    t.integer "number"
    t.text "long_answer"
    t.text "short_answer"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_id"], name: "index_cpd_audit_level_responses_on_cpd_audit_id"
    t.index ["cpd_audit_level_question_id"], name: "index_cpd_audit_level_responses_on_cpd_audit_level_question_id"
    t.index ["cpd_audit_level_section_id"], name: "index_cpd_audit_level_responses_on_cpd_audit_level_section_id"
  end

  create_table "cpd_audit_level_sections", force: :cascade do |t|
    t.bigint "cpd_audit_level_id"
    t.string "title"
    t.integer "position"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_level_id"], name: "index_cpd_audit_level_sections_on_cpd_audit_level_id"
  end

  create_table "cpd_audit_levels", force: :cascade do |t|
    t.string "title"
    t.text "determinations"
    t.text "recommendations"
    t.boolean "conflict_of_interest"
    t.boolean "can_request_exemption"
    t.boolean "can_request_extension"
    t.integer "days_to_submit"
    t.integer "days_to_review"
    t.integer "days_to_declare_conflict"
    t.integer "days_to_request_exemption"
    t.integer "days_to_request_extension"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "cpd_audit_review_items", force: :cascade do |t|
    t.bigint "cpd_audit_review_id"
    t.integer "item_id"
    t.string "item_type"
    t.string "recommendation"
    t.text "comments"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_review_id"], name: "index_cpd_audit_review_items_on_cpd_audit_review_id"
  end

  create_table "cpd_audit_reviews", force: :cascade do |t|
    t.bigint "cpd_audit_level_id"
    t.bigint "cpd_audit_id"
    t.integer "user_id"
    t.string "user_type"
    t.date "due_date"
    t.text "comments"
    t.string "recommendation"
    t.boolean "conflict_of_interest"
    t.text "conflict_of_interest_reason"
    t.datetime "submitted_at"
    t.string "status"
    t.text "status_steps"
    t.text "wizard_steps"
    t.string "token"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_id"], name: "index_cpd_audit_reviews_on_cpd_audit_id"
    t.index ["cpd_audit_level_id"], name: "index_cpd_audit_reviews_on_cpd_audit_level_id"
  end

  create_table "cpd_audits", force: :cascade do |t|
    t.bigint "cpd_audit_level_id"
    t.integer "user_id"
    t.string "user_type"
    t.date "due_date"
    t.date "notification_date"
    t.date "extension_date"
    t.string "determination"
    t.boolean "conflict_of_interest"
    t.text "conflict_of_interest_reason"
    t.boolean "exemption_request"
    t.text "exemption_request_reason"
    t.boolean "extension_request"
    t.text "extension_request_reason"
    t.date "extension_request_date"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.datetime "reviewed_at"
    t.datetime "closed_at"
    t.string "status"
    t.text "status_steps"
    t.text "wizard_steps"
    t.string "token"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_audit_level_id"], name: "index_cpd_audits_on_cpd_audit_level_id"
  end

  create_table "cpd_categories", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "cpd_cycles", force: :cascade do |t|
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "required_score"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "cpd_rules", force: :cascade do |t|
    t.bigint "cpd_cycle_id"
    t.integer "ruleable_id"
    t.string "ruleable_type"
    t.text "credit_description"
    t.string "formula"
    t.integer "max_credits_per_cycle"
    t.integer "max_cycles_can_carry_forward"
    t.boolean "unavailable", default: false
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_cycle_id"], name: "index_cpd_rules_on_cpd_cycle_id"
  end

  create_table "cpd_special_rule_mates", force: :cascade do |t|
    t.bigint "cpd_rule_id"
    t.bigint "cpd_special_rule_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_rule_id"], name: "index_cpd_special_rule_mates_on_cpd_rule_id"
    t.index ["cpd_special_rule_id"], name: "index_cpd_special_rule_mates_on_cpd_special_rule_id"
  end

  create_table "cpd_special_rules", force: :cascade do |t|
    t.bigint "cpd_cycle_id"
    t.integer "max_credits_per_cycle"
    t.string "category"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_cycle_id"], name: "index_cpd_special_rules_on_cpd_cycle_id"
  end

  create_table "cpd_statement_activities", force: :cascade do |t|
    t.bigint "cpd_statement_id"
    t.bigint "cpd_activity_id"
    t.bigint "cpd_category_id"
    t.bigint "original_id"
    t.integer "amount"
    t.integer "amount2"
    t.text "description"
    t.integer "carry_over"
    t.integer "score"
    t.integer "carry_forward"
    t.text "reduced_messages"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_activity_id"], name: "index_cpd_statement_activities_on_cpd_activity_id"
    t.index ["cpd_category_id"], name: "index_cpd_statement_activities_on_cpd_category_id"
    t.index ["cpd_statement_id"], name: "index_cpd_statement_activities_on_cpd_statement_id"
    t.index ["original_id"], name: "index_cpd_statement_activities_on_original_id"
  end

  create_table "cpd_statements", force: :cascade do |t|
    t.bigint "cpd_cycle_id"
    t.integer "user_id"
    t.string "user_type"
    t.string "token"
    t.integer "score"
    t.boolean "confirm_read"
    t.boolean "confirm_factual"
    t.boolean "confirm_readonly"
    t.datetime "submitted_at"
    t.text "wizard_steps"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_cycle_id"], name: "index_cpd_statements_on_cpd_cycle_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "template_name"
    t.string "subject"
    t.string "from"
    t.string "bcc"
    t.string "cc"
    t.string "content_type"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "roles_mask"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
