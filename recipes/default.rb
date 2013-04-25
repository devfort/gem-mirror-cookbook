chef_gem "rubygems-mirror"

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
}.each do |src, target|
  template target do
    source src
    owner node.gem_mirror.user
    group node.gem_mirror.user
    mode "0644"
  end
end

service "gem-mirror" do
  provider Chef::Provider::Service::Upstart
  action :start
end

log "Started mirroring RubyGems; run `while true; do find #{node.gem_mirror.data_dir}/gems/ -maxdepth 1|wc -l; sleep 3; done` to monitor mirroring progress."
