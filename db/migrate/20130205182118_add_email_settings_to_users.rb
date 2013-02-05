class AddEmailSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_recommended, :boolean, :default => true
    add_column :users, :email_channel_post, :boolean, :default => true
    add_column :users, :email_newsletter, :boolean, :default => true
  end
end
