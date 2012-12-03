class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :username, :null => false
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.string :status, :default => 'active'
      t.references :user
    end

    add_index :accounts, :user_id
    add_index :accounts, [:provider, :uid], unique: true
  end
end
