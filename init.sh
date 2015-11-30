#!/bin/sh

vagrant init 'ubuntu-14.04-x64'
vagrant up
vagrant ssh-config > ssh_config

patch -p0 <<PATCH
diff --git Vagrantfile Vagrantfile
index f2f3b07..2106cc5 100644
--- Vagrantfile
+++ Vagrantfile
@@ -26,7 +26,7 @@ Vagrant.configure(2) do |config|

   # Create a private network, which allows host-only access to the machine
   # using a specific IP.
-  # config.vm.network "private_network", ip: "192.168.33.10"
+  config.vm.network "private_network", ip: "192.168.33.10"

   # Create a public network, which generally matched to bridged network.
   # Bridged networks make the machine appear as another physical device on
@@ -68,4 +68,9 @@ Vagrant.configure(2) do |config|
   #   sudo apt-get update
   #   sudo apt-get install -y apache2
   # SHELL
+
+  config.vm.provision "ansible" do |ansible|
+    ansible.playbook = "provisioning/site.yml"
+    ansible.limit = "all"
+  end
 end
PATCH

cat << EOS > hosts
[development]
default
EOS

mkdir provisioning

cat << YAML > provisioning/site.yml
---
- include: base.yml
YAML

cat << YAML > provisioning/base.yml
---
- name: update package cache
  hosts: all
  sudo: true
  tasks:
  - apt: update_cache=yes cache_valid_time=3600

- name: some base packages are installed
  hosts: all
  sudo: true
  tasks:
  - apt: name={{ item }} state=latest
    with_items:
      - unzip
      - git
YAML

mkdir provisioning/roles
touch provisioning/roles/.keep

ansible default -m ping
vagrant reload --provision

gibo Vagrant > .gitignore
