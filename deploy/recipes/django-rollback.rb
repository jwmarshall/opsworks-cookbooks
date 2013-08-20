node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'other'
    Chef::Log.debug("Skipping deploy::django-rollback application #{application} as it is not of type 'other'")
    next
  end

  deploy deploy[:deploy_to] do
    user deploy[:user]
    #environment "RAILS_ENV" => deploy[:rails_env], "RUBYOPT" => ""
    action "rollback"
    restart_command "sleep #{deploy[:sleep_before_restart]} && #{node[:opsworks][:django_stack][:restart_command]}"
    
    only_if do
      File.exists?(deploy[:current_path])
    end
  end
end
