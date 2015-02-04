file "/var/www/index.html" do
  action :delete
end

web_app "localhost" do
  template "localhost.conf.erb"
end

modules = [
  "cgi",
  "negotiation",
  "autoindex",
  "reqtimeout",
  "env",
  "setenvif",
  "auth_basic",
  "authn_file",
  "authz_default",
  "authz_groupfile",
  "authz_user"
]

modules.each do |mod|
  bash "disable_apache_module_#{mod}" do
    user "root"
    code <<-EOH
    a2dismod #{mod}
    EOH
    not_if { File.exists?("/etc/apache2/mods-enabled/#{mod}") }
  end
end

if node['platform_family'] == 'debian'
  template "/etc/apache2/conf-enabled/vdd_apache.conf" do
    source "vdd_apache.conf.erb"
    mode "0644"
    notifies :restart, "service[apache2]", :delayed
  end
else
  template "/etc/apache2/conf.d/vdd_apache.conf" do
    source "vdd_apache.conf.erb"
    mode "0644"
    notifies :restart, "service[apache2]", :delayed
  end
end
