#!/bin/bash -e
sysctl -wq kernel.shmmax=17179869184
sysctl -wq net.ipv6.conf.lo.disable_ipv6=0
/opt/opscode/embedded/bin/runsvdir-start &
if [ -f "/root/chef_configured" ]
  then
    echo -e "\nChef Server already configured!\n"
    chef-server-ctl status
  else
    echo -e "\nNew install of Chef-Server!"
    apt-get update
    /usr/local/bin/configure_chef.sh
fi
#curl https://packages.chef.io/files/stable/chefdk/2.3.4/ubuntu/14.04/chefdk_2.3.4-1_amd64.deb -O --insecure && dpkg -i chefdk_2.3.4-1_amd64.deb
#rackup -o 0.0.0.0 /opt/chef-browser/config.ru
tail -F /opt/opscode/embedded/service/*/log/current
