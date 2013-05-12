class AddEventToStat < ActiveRecord::Migration
  def change
    add_column :stats, :event, :string
  end
end
