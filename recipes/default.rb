package "ruby1.9.1"
gem_package "rubygems-mirror"

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

log "Started mirroring RubyGems; tail /var/log/upstart/gem-mirror.log to monitor."
