class AddSocialLinksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :social_links, :text, :default => "[]"
  end
end
