include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "pip-install-requirements" do
    cwd "#{deploy[:current_path]}"
    command "pip install -r requirements.txt"
  end

  execute "django-syncdb" do
    cwd "#{deploy[:current_path]}/#{application}"
    command "python manage.py syncdb --noinput"
  end

  execute "django-migrate" do
    cwd "#{deploy[:current_path]}/#{application}"
    command "python manage.py migrate"
  end

  include_recipe "supervisor"

  supervisor_service "#{application}" do
    user "deploy"
    command "python manage.py runserver 0.0.0.0:8080"
    autostart true
    directory "#{deploy[:current_path]}/#{application}"
    action :enable
  end
end
