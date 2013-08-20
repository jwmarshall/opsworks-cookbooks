include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'custom'
    Chef::Log.debug("Application type is: #{deploy[:application_type]}")
    Chef::Log.debug("Skipping deploy::django application #{application} as it is not a 'custom' app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_django do
    deploy_data deploy
    app application
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end
