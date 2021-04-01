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

ActiveRecord::Schema.define(version: 3) do

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "cpd_activities", force: :cascade do |t|
    t.bigint "cpd_cycle_id"
    t.bigint "cpd_category_id"
    t.string "title"
    t.integer "position"
    t.string "formula"
    t.string "amount_label"
    t.string "amount2_label"
    t.integer "max_credits_per_cycle"
    t.integer "max_cycles_can_carry_forward"
    t.boolean "requires_upload_file", default: false
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_category_id"], name: "index_cpd_activities_on_cpd_category_id"
    t.index ["cpd_cycle_id"], name: "index_cpd_activities_on_cpd_cycle_id"
  end

  create_table "cpd_categories", force: :cascade do |t|
    t.bigint "cpd_cycle_id"
    t.string "title"
    t.integer "position"
    t.integer "max_credits_per_cycle"
    t.integer "max_cycles_can_carry_forward"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["cpd_cycle_id"], name: "index_cpd_categories_on_cpd_cycle_id"
  end

  create_table "cpd_cycles", force: :cascade do |t|
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "required_score"
    t.string "token"
    t.datetime "updated_at"
    t.datetime "created_at"
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

end
