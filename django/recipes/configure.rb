include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart django app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:django_stack][:restart_command]
    action :nothing
  end

  node.default[:deploy][application][:database][:adapter] = OpsWorks::DjangoConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/database.py" do
    source "database.py.erb"
    cookbook 'django'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database], :environment => deploy[:django_env])

    notifies :run, "execute[restart Django app #{application}]"

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

#  template "#{deploy[:deploy_to]}/shared/config/memcached.py" do
#    source "memcached.yml.erb"
#    cookbook 'rails'
#    mode "0660"
#    group deploy[:group]
#    owner deploy[:user]
#    variables(
#      :memcached => deploy[:memcached] || {},
#      :environment => deploy[:rails_env]
#    )
#
#    notifies :run, "execute[restart Rails app #{application}]"
#
#    only_if do
#      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
#    end
#  end
end
