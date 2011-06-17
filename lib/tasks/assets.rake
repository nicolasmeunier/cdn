###################################################################################################
#          RAKE tasks for the asset management , 
#                - Compass compiler   --> assets:compile
#                - Jammit bundler     --> assets:bundle
#                - Clean all          --> assets:clean
#                - Compile and bundle --> assets (runs assets:compile and assets:bundle)
####################################################################################################

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
task :assets => ['assets:compile', 'assets:bundle']