class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :follower
      t.references :followed

      t.timestamps
    end

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
  end
end
