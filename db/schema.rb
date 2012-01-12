# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111123172058) do

  create_table "exalts", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                                                   :null => false
    t.string   "name",                                                   :null => false
    t.string   "gender",        :limit => 1,                             :null => false
    t.boolean  "active",                     :default => true,           :null => false
    t.integer  "total_xp",                   :default => 0,              :null => false
    t.integer  "unspent_xp",                 :default => 0,              :null => false
    t.string   "caste",                                                  :null => false
    t.integer  "strength",                   :default => 1,              :null => false
    t.integer  "dexterity",                  :default => 1,              :null => false
    t.integer  "stamina",                    :default => 1,              :null => false
    t.integer  "charisma",                   :default => 1,              :null => false
    t.integer  "manipulation",               :default => 1,              :null => false
    t.integer  "appearance",                 :default => 1,              :null => false
    t.integer  "perception",                 :default => 1,              :null => false
    t.integer  "intelligence",               :default => 1,              :null => false
    t.integer  "wits",                       :default => 1,              :null => false
    t.integer  "archery",                    :default => 0,              :null => false
    t.integer  "athletics",                  :default => 0,              :null => false
    t.integer  "awareness",                  :default => 0,              :null => false
    t.integer  "bureaucracy",                :default => 0,              :null => false
    t.integer  "dodge",                      :default => 0,              :null => false
    t.integer  "integrity",                  :default => 0,              :null => false
    t.integer  "investigation",              :default => 0,              :null => false
    t.integer  "larceny",                    :default => 0,              :null => false
    t.integer  "linguistics",                :default => 0,              :null => false
    t.integer  "lore",                       :default => 0,              :null => false
    t.integer  "martial_arts",               :default => 0,              :null => false
    t.integer  "medicine",                   :default => 0,              :null => false
    t.integer  "melee",                      :default => 0,              :null => false
    t.integer  "occult",                     :default => 0,              :null => false
    t.integer  "performance",                :default => 0,              :null => false
    t.integer  "presence",                   :default => 0,              :null => false
    t.integer  "resistance",                 :default => 0,              :null => false
    t.integer  "ride",                       :default => 0,              :null => false
    t.integer  "sail",                       :default => 0,              :null => false
    t.integer  "socialise",                  :default => 0,              :null => false
    t.integer  "stealth",                    :default => 0,              :null => false
    t.integer  "survival",                   :default => 0,              :null => false
    t.integer  "thrown",                     :default => 0,              :null => false
    t.integer  "war",                        :default => 0,              :null => false
    t.string   "craft",                      :default => "'--- {}\n\n'", :null => false
    t.string   "favoured"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",   :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean  "contact_me",                            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
