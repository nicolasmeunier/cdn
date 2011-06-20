#---
# Excerpted from "Agile Web Development with Rails, 3rd Ed.",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rails3 for more book information.
#---
# be sure to change these

# deploy
# |-- deploy:update
# |---- deploy:update_code
# |------ Code update based on the :deploy_via
# |------ deploy:finalize_update
# |---- deploy:symlink
# |-- deploy:restart

set :user, 'ubuntu'
set :domain, 'ec2-204-236-177-181.us-west-1.compute.amazonaws.com'
set :application, 'cdn'
set :rails_env, 'production'

# file paths
set :repository, "git@github.com:nicolasmeunier/cdn.git"  # Your clone URL
set :deploy_to, "/home/#{user}/www/cabinguru"

# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain, :asset_host_syncher => true
role :db, domain, :primary => true

# you might need to set this if you aren't seeing password prompts
# default_run_options[:pty] = true

# As Capistrano executes in a non-interactive mode and therefore doesn't cause
# any of your shell profile scripts to be run, the following might be needed
# if (for example) you have locally installed gems or applications.  Note:
# this needs to contain the full values for the variables set, not simply
# the deltas.
# default_environment['PATH']='<your paths>:/usr/local/bin:/usr/bin:/bin'
# default_environment['GEM_PATH']='<your paths>:/usr/lib/ruby/gems/1.8'

# miscellaneous options

# Might be needed to turn off remote_cache http://groups.google.com/group/capistrano/browse_thread/thread/b14635454d40087b/8bbc4d7d286fccc8?pli=1
#set :deploy_via, :remote_cache
set :git_shallow_clone, 1   # As a remote cache alternative

set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

# Per http://help.github.com/capistrano/
default_run_options[:pty] = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true


# task which causes Passenger to initiate a restart
namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end

# # optional task to reconfigure databases
after "deploy:update_code", :configure_database
after"deploy:update_code", :configure_asset_hash
#before "deploy:symlink", "s3_asset_host:synch_public"

# Removed for first deployment
# TODO: Uncomment
#after "configure_database", :start_delayed_job_workers

desc "copy database.yml into the current release path"
task :configure_database, :roles => :app do
  db_config = "#{deploy_to}/config/database.yml"
  run "cp #{db_config} #{release_path}/config/database.yml"
end

task :configure_asset_hash, :roles => :app do
  hash = (`git rev-parse HEAD` || "").chomp
  asset_yml = "hash: " + hash
  asset_config = "#{release_path}/config/asset_hash.yml"
  run "echo '#{asset_yml}' > #{asset_config}"
end
