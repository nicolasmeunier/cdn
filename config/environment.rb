# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cdn::Application.initialize!

config.load_paths << "#{RAILS_ROOT}/vendor/plugins/synch_s3_asset_host/s3sync/"