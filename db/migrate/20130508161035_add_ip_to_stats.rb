class AddIpToStats < ActiveRecord::Migration
  def change
    add_column :stats, :ip_address, :string
  end
end
