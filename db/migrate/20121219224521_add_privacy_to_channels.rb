class AddPrivacyToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :privacy, :string, :default => 'public'
  end
end
