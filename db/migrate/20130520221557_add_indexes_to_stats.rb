class AddIndexesToStats < ActiveRecord::Migration
  def change
    add_index :stats, :post_id
    add_index :stats, :post_user_id
    add_index :stats, :referer_host
    add_index :stats, :created_at
    add_index :stats, :event
  end
end
