class AddColorThemeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :color_theme, :string
  end
end
