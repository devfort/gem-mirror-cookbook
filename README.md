Description
===========

This cookbook configures the machine as a mirror of http://rubygems.org/.

Requirements
============

Platform
--------

* Ubuntu 12.10 (that's all we support at /dev/fort, so that's all I've tested in for now.)

Attributes
==========

Cookbook attributes are named under the `gem_mirror` namespace.

* `default['gem_mirror']['data_dir']` - directory to store mirrored gems in, defaults to `/data/rubygems`
* `default['gem_mirror']['user']` - user to host gem mirror as, defaults to `fort`

Recipes
=======

The main entrypoint for this cookbook is the `default` recipe.

Usage
=====

Include `gem-mirror` and it will start replicating http://rubygems.org. This will take a _very_ long time (probably a day or two), and require tens of gigabytes of storage. You have been warned.

You can keep an eye on the mirroring progress by running `while true; do find #{node.gem_mirror.data_dir}/gems/ -maxdepth 1|wc -l; sleep 3; done`.

# TODO
- What else do we install/configure
- Mirror usage