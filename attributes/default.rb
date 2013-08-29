default['gem_mirror']['data_dir'] = '/data/rubygems'
default['gem_mirror']['user'] = 'fort'

default['gem_mirror']['apache']['listen_hostname'] = '*'
default['gem_mirror']['apache']['listen_port'] = '80'

override['apache']['default_site_enabled'] = false

override[:rbenv][:git_repository] = "https://github.com/sstephenson/rbenv.git"
override[:ruby_build][:git_repository] = "https://github.com/sstephenson/ruby-build.git"
