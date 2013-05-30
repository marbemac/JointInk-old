revision_file = Rails.root.join("REVISION")
if File.exist?(revision_file)
  ENV["RAILS_APP_VERSION"] = File.read(revision_file)
  ENV["ETAG_VERSION_ID"] = File.read(revision_file)
end