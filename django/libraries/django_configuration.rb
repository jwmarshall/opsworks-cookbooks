module OpsWorks
  module DjangoConfiguration
    def self.determine_database_adapter(app_name, app_config, app_root_path, options = {})
      options = {
        :consult_requirements => true,
        :force => false
      }.update(options)
      if options[:force] || app_config[:database][:adapter].blank?
        Chef::Log.info("No database adapter specified for #{app_name}, guessing")
        adapter = ''

        if options[:consult_requirements] and File.exists?("#{app_root_path}/requirements")
          pip_list = `cd #{app_root_path}; /usr/local/bin/pip list`
          adapter = if pip_list.include?('MySQL-python')
            Chef::Log.info("Looks like #{app_name} uses mysql in its requirements.txt")
            'mysql'
          else if pip_list.include?('psycopg2')
            Chef::Log.info("Looks like #{app_name} uses psycopg2 in its requirements.txt")
            'postgresql_psycopg2'
          else
            Chef::Log.info("Gem mysql2 not found in the Gemfile of #{app_name}, defaulting to mysql")
            'mysql'
          end
        else # no requirements.txt - default to mysql
          adapter = 'mysql'
        end

        adapter
      else
        app_config[:database][:adapter]
      end
    end

    def self.install_requirements(app_name, app_config, app_root_path)
      if File.exists?("#{app_root_path}/requirements.txt")
        Chef::Log.info("Requirements file detected. Running pip install.")
        Chef::Log.info("sudo su deploy -c 'cd #{app_root_path} && /usr/local/bin/pip install -r requirements.txt'")
        Chef::Log.info(`sudo su deploy -c 'cd #{app_root_path} && /usr/local/bin/pip install -r requirements.txt 2>&1'`)
      end
    end
  end
end
