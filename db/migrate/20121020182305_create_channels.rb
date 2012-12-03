class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.string :slug
      t.string :description
      t.string :status, :default => 'active'
      t.string :photo, :default => nil
      t.string :cover_photo, :default => nil
      t.references :user
    end

    add_index :channels, :slug, :unique => true
    add_index :channels, :user_id
  end
end