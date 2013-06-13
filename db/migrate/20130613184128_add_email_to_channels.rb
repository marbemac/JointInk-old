class AddEmailToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :email, :string
    add_index :channels, :email, :unique => true
  end
end