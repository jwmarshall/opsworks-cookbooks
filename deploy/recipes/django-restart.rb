#
# Cookbook Name:: deploy
# Recipe:: django-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'custom'
    Chef::Log.debug("Skipping deploy::django-restart application #{application} as it is not a 'custom' app")
    next
  end
  
  execute "restart Server" do
    cwd deploy[:current_path]
    command "sleep #{deploy[:sleep_before_restart]} && #{node[:opsworks][:django_stack][:restart_command]}"
    action :run
    
    only_if do 
      File.exists?(deploy[:current_path])
    end
  end
    
end


