class AddDomainToUsers < ActiveRecord::Migration
  def change
    add_column :users, :domain, :string
    add_index :users, :domain
  end
end