require 'soulmate/server'

if ENV["OPENREDIS_URL"]
  Soulmate.redis = ENV["OPENREDIS_URL"]
elsif Rails.env.development?
  Soulmate.redis = 'redis://127.0.0.1:6379/'
end