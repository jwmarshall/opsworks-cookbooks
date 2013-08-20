include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'other'
    Chef::Log.debug("Application type is: #{deploy[:application_type]}")
    Chef::Log.debug("Skipping deploy::django application #{application} as it is not of type 'other'")
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
