class CreatePostStats < ActiveRecord::Migration
  def change
    create_table :post_stats do |t|
      t.string :stat_type
      t.string :value, :default => nil
      t.string :ip_address, :default => nil
      t.string :referral_url
      t.integer :post_id
      t.integer :user_id, :default => nil
      t.references :post
      t.references :user
      t.timestamps
    end

    add_index :post_stats, :stat_type
    add_index :post_stats, :post_id
    add_index :post_stats, :ip_address
    add_index :post_stats, :user_id
    add_index :post_stats, :created_at
  end
end
