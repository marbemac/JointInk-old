class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|

      t.integer :channel_id
      t.datetime :channel_created
      t.string :channel_privacy
      t.integer :channel_privacy
      t.string :channel_status
      t.integer :channel_user_id

      t.integer :post_id
      t.datetime :post_published_at
      t.string :post_status
      t.string :post_style
      t.string :post_subtype
      t.string :post_type
      t.integer :post_user_id
      t.boolean :post_with_photo

      t.integer :user_id
      t.datetime :user_birthday
      t.datetime :user_created_at
      t.string :user_gender

      t.string :referer
      t.string :refererHost

      t.timestamps
    end
  end
end
