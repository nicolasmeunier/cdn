###################################################################################################
#          RAKE tasks for the asset management , 
#                - Compass compiler   --> assets:compile
#                - Jammit bundler     --> assets:bundle
#                - Clean all          --> assets:clean
#                - Compile and bundle --> assets (runs assets:compile and assets:bundle)
####################################################################################################
require 'securerandom'

desc "Compiles SASS using Compass"
task 'sass:compile' do
  system 'compass compile'
end
 
namespace :assets do
  desc "Compiles all CSS assets"
  task :compile => ['sass:compile']
  
  desc "Bundles all assets with Jammit"
  task :bundle => :environment do
    system "cd #{Rails.root} && jammit"
  end
  
  desc "Copy css images from stylesheets/images to assets/images"
  task :copy_css_images => :environment do
    #Cleaning public/assets/images and copying fresh css images from stylesheets/images
    system "cd #{Rails.root} && rm -r public/assets/images/ && cp -r public/stylesheets/images public/assets"
  end
  
  desc "Generating asset_hash used for S3 deployment"
  task :generate_hash => [ :environment ] do
    rdm = SecureRandom.hex(16) 
    file = open('config/asset_hash.yml', 'wb')
    file.write("hash: " + rdm)
    file.close
  end
  
  desc "Removes all compiled and bundled assets"
  task :clean => :environment do
    files = []
    files << ['assets']
    files << ['javascripts', 'compiled']
    files << ['stylesheets', 'compiled']
    files = files.map { |path| Dir[Rails.root.join('public', *path, '*.*')] }.flatten
    
    puts "Removing:"
    files.each do |file|
      puts "  #{file.gsub(Rails.root.to_s + '/', '')}"
    end   
    File.delete *files
  end
end
 
desc "Compiles and bundles all assets"
task :assets => ['assets:compile', 'assets:bundle', 'assets:generate_hash', 'assets:copy_css_images']

namespace :server_env do
  namespace :hash do
    task :to_production => [ :environment, :assets ] do
      Rake::Task["server_env:hash:addHashToEnvironment"].execute({ app: 'example-production' })
    end
    task :to_staging => [ :environment ] do
      Rake::Task["server_env:hash:addHashToEnvironment"].execute({ app: 'example-staging' })
    end
    task :addHashToEnvironment, [ :app ]  => [ :environment ] do |t, args|
      hash = (`git rev-parse HEAD` || "").chomp
      Rake::Task["heroku:config:add"].execute({ app: args[:app], value: "ASSET_HASH=#{hash}" })
    end
  end
  
  namespace :config do
    desc "Set a configuration parameter on Heroku"
    task :add, [ :app, :value ] => :environment do |t, args|
      app = "--app #{args[:app]}" if args[:app]
      value = args[:value]
      logger.debug("[#{Time.now}] running 'heroku config:add #{app} #{value}'")
      `heroku config:add #{app} #{value}`
    end
  end  
end