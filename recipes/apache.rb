directory "/var/www" do
  owner "www-data"
  group "www-data"
end

directory "/var/lock/apache2" do
  owner "www-data"
  group "www-data"
end

file "/var/www/index.html" do
  action :delete
end

link "/home/vagrant/sites" do
  to "/var/www"
end

# Add vagrant to www-data group
group "www-data" do
  action :modify
  members "vagrant"
  append true
end

web_app "localhost" do
  template "localhost.conf.erb"
end

node.default["apache"]["user"] = "www-data"
node.default["apache"]["group"] = "www-data"

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

template "/etc/apache2/conf-enabled/vdd_apache.conf" do
  source "vdd_apache.conf.erb"
  mode "0644"
  notifies :restart, "service[apache2]", :delayed
end
