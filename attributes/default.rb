default['gem_mirror']['user'] = 'fort'
default['gem_mirror']['data_dir'] = '/data/rubygems'

default['gem_mirror']['apache']['listen_hostname'] = 'gem.fort'
default['gem_mirror']['apache']['listen_port'] = '80'

override['apache']['default_site_enabled'] = false
