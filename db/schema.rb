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

ActiveRecord::Schema.define(:version => 20130210222809) do

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

  create_table "amazing_facts", :force => true do |t|
    t.text "content"
  end

  create_table "attachinary_files", :force => true do |t|
    t.integer  "attachinariable_id"
    t.string   "attachinariable_type"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "attachinary_files", ["attachinariable_type", "attachinariable_id", "scope"], :name => "by_scoped_parent"

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "description"
    t.string   "status",      :default => "active"
    t.string   "photo"
    t.string   "cover_photo"
    t.integer  "user_id"
    t.string   "privacy",     :default => "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "posts_count"
  end

  add_index "channels", ["posts_count"], :name => "index_channels_on_posts_count"
  add_index "channels", ["slug"], :name => "index_channels_on_slug", :unique => true
  add_index "channels", ["user_id"], :name => "index_channels_on_user_id"

  create_table "channels_posts", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "channel_id"
  end

  add_index "channels_posts", ["channel_id"], :name => "index_channels_posts_on_channel_id"
  add_index "channels_posts", ["post_id", "channel_id"], :name => "index_channels_posts_on_post_id_and_channel_id", :unique => true
  add_index "channels_posts", ["post_id"], :name => "index_channels_posts_on_post_id"

  create_table "post_stats", :force => true do |t|
    t.string   "stat_type"
    t.string   "value"
    t.string   "ip_address"
    t.string   "referral_url"
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "post_stats", ["created_at"], :name => "index_post_stats_on_created_at"
  add_index "post_stats", ["ip_address"], :name => "index_post_stats_on_ip_address"
  add_index "post_stats", ["post_id"], :name => "index_post_stats_on_post_id"
  add_index "post_stats", ["stat_type"], :name => "index_post_stats_on_stat_type"
  add_index "post_stats", ["user_id"], :name => "index_post_stats_on_user_id"

# Could not dump table "posts" because of following StandardError
#   Unknown type 'hstore' for column 'photo_exif'

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "channel_id"
  end

  add_index "relationships", ["channel_id"], :name => "index_relationships_on_channel_id"
  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id", "channel_id"], :name => "index_relationship_follow_follower_channel_ids", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

# Could not dump table "share_actions" because of following StandardError
#   Unknown type 'hstore' for column 'permissions'

# Could not dump table "shares" because of following StandardError
#   Unknown type 'hstore' for column 'permissions'

  create_table "sources", :force => true do |t|
    t.string "name", :null => false
    t.string "url",  :null => false
    t.string "slug"
  end

  add_index "sources", ["slug"], :name => "index_sources_on_slug", :unique => true

# Could not dump table "users" because of following StandardError
#   Unknown type 'hstore' for column 'theme_data'

end
