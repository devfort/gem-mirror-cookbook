# HACK: Fix git<1.8.4 on Ubuntu 13.04 (http://tickets.opscode.com/browse/CHEF-3940)
directory "/root" do
  mode "0755"
end

# Install a trustworthy version of Ruby
include_recipe "rbenv"
include_recipe "rbenv::ruby_build"
rbenv_ruby "1.9.3-p385" do
  global true
end
rbenv_gem "bundler" do
  ruby_version "1.9.3-p385"
end

[
  node.gem_mirror.data_dir,
  "/home/#{node.gem_mirror.user}/.gem",
  "/home/#{node.gem_mirror.user}/rubygems-mirror",
].each do |dir|
  directory dir do
    owner node.gem_mirror.user
    group node.gem_mirror.user
    mode "0755"
    recursive true
  end
end

# Use @huacnlee/rubygems-mirror, per http://www.hackhowtofaq.com/blog/mirror-ruby-gems-locally/
# HACK: @huacnlee/rubygems-mirror isn't on rubygems, so install it with bundler
remote_file "/home/#{node.gem_mirror.user}/rubygems-mirror/Gemfile" do
  source "https://raw.github.com/huacnlee/rubygems-mirror/master/Gemfile"
  owner node.gem_mirror.user
  group node.gem_mirror.user
  mode "0644"
end
ruby_block "add-rubygems-mirror-to-gemfile" do
  block do
    file = Chef::Util::FileEdit.new("/home/#{node.gem_mirror.user}/rubygems-mirror/Gemfile")
    file.insert_line_if_no_match(
      "gem 'rubygems-mirror'",
      "gem 'rubygems-mirror', '0.0.0', :git => 'https://github.com/huacnlee/rubygems-mirror.git'"
    )
    file.write_file
  end
end

# HACK: su to change user because script/execute doesn't set user (http://tickets.opscode.com/browse/CHEF-1523, via http://serverfault.com/questions/402881/execute-as-vagrant-user-not-root-with-chef-solo)
execute "install-gem-mirror" do
  command "su #{node.gem_mirror.user} -lc 'cd /home/#{node.gem_mirror.user}/rubygems-mirror/ && bundle install'"
end

{
  "gem-mirrorrc.erb" => "/home/#{node.gem_mirror.user}/.gem/.mirrorrc",
  "services/gem-mirror.conf.erb" => "/etc/init/gem-mirror.conf",
  "services/gem-mirror-shim.conf.erb" => "/etc/init/gem-mirror-shim.conf",
}.each do |src, target|
  template target do
    source src
    owner node.gem_mirror.user
    group node.gem_mirror.user
    mode "0644"
  end
end

service "gem-mirror-shim" do
  provider Chef::Provider::Service::Upstart
  action :restart
end

# Serve the gems (when they finish mirroring)
web_app "gem_mirror" do
  docroot node.gem_mirror.data_dir
  hostname node.gem_mirror.apache.listen_hostname
  port node.gem_mirror.apache.listen_port
end

log "Started mirroring RubyGems; tail /var/log/upstart/gem-mirror.log to monitor."
