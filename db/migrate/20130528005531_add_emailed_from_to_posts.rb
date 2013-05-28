class AddEmailedFromToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :emailed_from, :string
  end
end
