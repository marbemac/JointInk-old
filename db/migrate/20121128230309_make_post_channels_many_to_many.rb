class MakePostChannelsManyToMany < ActiveRecord::Migration
  def change
    create_table :channels_posts do |t|
      t.timestamps
      t.references :user
      t.references :post
      t.references :channel
    end

    add_index :channels_posts, :post_id
    add_index :channels_posts, :channel_id
    add_index :channels_posts, [:post_id, :channel_id], unique: true
  end
end
