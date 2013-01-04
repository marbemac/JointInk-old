class AddVotesCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :votes_count, :integer, :default => 0
    add_index :posts, :votes_count, :order => {:name => :desc}
  end
end
