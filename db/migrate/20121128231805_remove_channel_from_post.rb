class RemoveChannelFromPost < ActiveRecord::Migration
  def change
    remove_column :posts, :channel_id
  end
end
