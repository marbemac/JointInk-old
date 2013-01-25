class AddSearchIndexToChannels < ActiveRecord::Migration
  def up
    execute "create index channels_name on channels using gin(to_tsvector('english', name))"
    execute "create index channels_description on channels using gin(to_tsvector('english', description))"
  end

  def down
    execute "drop index channels_name"
    execute "drop index channels_description"
  end
end
