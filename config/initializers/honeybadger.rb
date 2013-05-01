if Rails.env == 'production'
  Honeybadger.configure do |config|
    config.api_key = '02bbb1da'
  end
end