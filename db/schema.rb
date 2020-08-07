# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_07_203232) do

  create_table "boards", force: :cascade do |t|
    t.boolean "active", default: false
  end

  create_table "cells", force: :cascade do |t|
    t.integer "x"
    t.integer "y"
  end

  create_table "crystals", force: :cascade do |t|
    t.integer "cell_id"
    t.string "state", default: "dead"
    t.integer "board_id"
    t.index ["cell_id"], name: "index_crystals_on_cell_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.integer "cell_id"
    t.string "name"
    t.string "color"
    t.index ["cell_id"], name: "index_tokens_on_cell_id"
  end

end
