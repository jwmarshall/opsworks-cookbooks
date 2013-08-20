default[:opsworks][:django_stack][:name] = "uwsgi"
case node[:opsworks][:django_stack][:name]
when "uwsgi"
  default[:opsworks][:django_stack][:recipe] = "uwsgi::django"
  default[:opsworks][:django_stack][:needs_reload] = true
  default[:opsworks][:django_stack][:service] = 'uwsgi'
  default[:opsworks][:django_stack][:restart_command] = 'touch tmp/restart.txt'
else
  raise "Unknown stack: #{node[:opsworks][:django_stack][:name].inspect}"
end
