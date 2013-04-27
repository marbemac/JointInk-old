CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => 'AKIAIQDM2Y5J44SJILXA',
      :aws_secret_access_key  => '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',
      #:region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
      #:hosts                  => 's3.example.com',             # optional, defaults to nil
      #:endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = 'jointink'                     # required
  config.fog_public     = true                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  config.asset_host       = 'http://static.jointink.com'
end