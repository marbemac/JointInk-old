class AddThemeToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :color_theme
    add_column :users, :theme_data, :hstore
  end
end
