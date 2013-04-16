class CreateOutreaches < ActiveRecord::Migration
  def change
    create_table :outreaches do |o|
      o.text :content
      o.string :url
    end
  end
end
