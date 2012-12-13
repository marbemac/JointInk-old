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

ActiveRecord::Schema.define(:version => 20121213181010) do

  create_table "accounts", :force => true do |t|
    t.string  "username",                       :null => false
    t.string  "provider"
    t.string  "uid"
    t.string  "token"
    t.string  "secret"
    t.string  "status",   :default => "active"
    t.integer "user_id"
  end

  add_index "accounts", ["provider", "uid"], :name => "index_accounts_on_provider_and_uid", :unique => true
  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "channels", :force => true do |t|
    t.string  "name"
    t.string  "slug"
    t.string  "description"
    t.string  "status",      :default => "active"
    t.string  "photo"
    t.string  "cover_photo"
    t.integer "user_id"
  end

  add_index "channels", ["slug"], :name => "index_channels_on_slug", :unique => true
  add_index "channels", ["user_id"], :name => "index_channels_on_user_id"

  create_table "channels_posts", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "channel_id"
  end

  add_index "channels_posts", ["channel_id"], :name => "index_posts_channels_on_channel_id"
  add_index "channels_posts", ["post_id", "channel_id"], :name => "index_posts_channels_on_post_id_and_channel_id", :unique => true
  add_index "channels_posts", ["post_id"], :name => "index_posts_channels_on_post_id"

# Could not dump table "posts" because of following StandardError
#   Unknown type 'hstore' for column 'photo_exif'

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string       "email"
    t.string       "encrypted_password",                    :default => "",                           :null => false
    t.string       "reset_password_token"
    t.datetime     "reset_password_sent_at"
    t.datetime     "remember_created_at"
    t.integer      "sign_in_count",                         :default => 0
    t.datetime     "current_sign_in_at"
    t.datetime     "last_sign_in_at"
    t.string       "current_sign_in_ip"
    t.string       "last_sign_in_ip"
    t.string       "confirmation_token"
    t.datetime     "confirmed_at"
    t.datetime     "confirmation_sent_at"
    t.string       "unconfirmed_email"
    t.string       "authentication_token"
    t.datetime     "created_at",                                                                      :null => false
    t.datetime     "updated_at",                                                                      :null => false
    t.string       "username"
    t.boolean      "username_reset",                        :default => false
    t.string       "name"
    t.string       "slug"
    t.string       "status",                                :default => "active"
    t.string       "gender"
    t.date         "birthday"
    t.string       "time_zone",                             :default => "Eastern Time (US & Canada)"
    t.text         "bio"
    t.boolean      "use_fb_image",                          :default => false
    t.string       "origin"
    t.string       "avatar"
    t.string       "cover_photo"
    t.string_array "roles",                  :limit => 255, :default => "{}"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

end
