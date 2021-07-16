require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
    config.storage :fog
    config.fog_provider = 'fog/aws'
    config.fog_directory  = ENV['BACKET_NAME'] # バケット名
    config.fog_public = false
    config.asset_host = "https://s3.amazonaws.com/#{ENV['BUCKET_NAME']}"
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['ACCESS_KEY_ID'], # アクセスキー
      aws_secret_access_key: ENV['SECRET_ACCESS_KEY'], # シークレットアクセスキー
      region: ENV['REGION'], # リージョン
      path_style: true
    }
end