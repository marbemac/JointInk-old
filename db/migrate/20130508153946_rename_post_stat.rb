class RenamePostStat < ActiveRecord::Migration
  def change
    remove_column :post_stats, :stat_type
    rename_table :post_stats, :post_votes
  end
end
