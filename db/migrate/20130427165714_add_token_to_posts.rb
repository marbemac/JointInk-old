class AddTokenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :token, :string
    add_index :posts, :token
  end
end
