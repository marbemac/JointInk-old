class AddAttributionLinkToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :attribution_link, :string
  end
end
