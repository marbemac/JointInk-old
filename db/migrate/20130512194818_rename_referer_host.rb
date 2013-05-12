class RenameRefererHost < ActiveRecord::Migration
  def change
    rename_column :stats, :refererHost, :referer_host
  end
end
