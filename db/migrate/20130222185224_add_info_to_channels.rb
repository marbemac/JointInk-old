class AddInfoToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :info, :text
  end
end
