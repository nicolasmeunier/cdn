require 'logger'

namespace :s3 do
    namespace :sync do
 
        def s3i
            @@s3 ||= s3i_open
        end
    
        #Config data for s3 are in config/s3.yml.
        def s3i_open
            s3_config = YAML.load_file(Rails.root.join("config/s3.yml")).symbolize_keys
            s3_key_id = s3_config[:production]['config']['S3_ACCESS_KEY_ID']
            s3_access_key = s3_config[:production]['config']['S3_SECRET_ACCESS_KEY']      
            RightAws::S3Interface.new(s3_key_id, s3_access_key, { logger: Rails.logger })
        end
        
        # uploads assets to s3 under assets/githash, deletes stale assets
        task :uploadToS3, [:to] => :environment do |t, args|
          from = File.join(Rails.root, 'public/assets')
          to = args[:to]
          hash = (`git rev-parse HEAD` || "").chomp

          #logger.info("[#{Time.now}] fetching keys from #{to}")
          existing_objects_hash = {}
          s3i.incrementally_list_bucket(to) do |response|
            response[:contents].each do |existing_object|
              next unless existing_object[:key].start_with?("assets/")
              existing_objects_hash[existing_object[:key]] = existing_object
            end
          end

          #logger.info("[#{Time.now}] copying from #{from} to s3:#{to} @ #{hash}")
          Dir.glob(from + "/**/*").each do |entry|
            next if File::directory?(entry)
            key = 'assets/'
            key += (hash + '/') if hash
            key += entry.slice(from.length + 1, entry.length - from.length - 1)
            existing_objects_hash.delete(key)
            #logger.info("[#{Time.now}] uploading #{key}")
            s3i.put(to, key, File.open(entry), { 'x-amz-acl' => 'public-read' })
          end

          existing_objects_hash.keys.each do |key|
            puts "deleting #{key}"
            s3i.delete(to, key)
          end
        end

        namespace :push do
          task :to_staging => [:environment] do
            Rake::Task["s3:sync:uploadToS3"].execute({ to: 'cwcdn0' })
          end
        end
        
          
    end        
end