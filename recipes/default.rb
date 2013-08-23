package "ruby1.9.1"

package "git"
gem_package "bundler"

# Use @huacnlee/rubygems-mirror, per http://www.hackhowtofaq.com/blog/mirror-ruby-gems-locally/
remote_file "/home/#{node.gem_mirror.user}/Gemfile" do
  source "https://raw.github.com/huacnlee/rubygems-mirror/master/Gemfile"
  owner node.gem_mirror.user
  group node.gem_mirror.user
  mode "0644"
end

ruby_block "include-bashrc-user" do
  block do
    file = Chef::Util::FileEdit.new("/home/#{node.gem_mirror.user}/Gemfile")
    file.insert_line_if_no_match(
      "gem 'rubygems-mirror'",
      "gem 'rubygems-mirror', '0.0.0', :git => 'https://github.com/huacnlee/rubygems-mirror'"
    )
    file.write_file
  end
end

[
  node.gem_mirror.data_dir,
  "/home/#{node.gem_mirror.user}/.gem",
].each do |dir|
  directory dir do
    owner node.gem_mirror.user
    group node.gem_mirror.user
    mode "0755"
  end
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

web_app "gem_mirror" do
  docroot node.gem_mirror.data_dir
  hostname node.gem_mirror.apache.listen_hostname
  port node.gem_mirror.apache.listen_port
end

log "Started mirroring RubyGems; tail /var/log/upstart/gem-mirror.log to monitor."
