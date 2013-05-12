class RemoveOutreach < ActiveRecord::Migration
  def change
    drop_table :outreaches
  end
end
