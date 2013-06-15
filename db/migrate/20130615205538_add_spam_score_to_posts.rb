class AddSpamScoreToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :spam_score, :float
  end
end
