#!/bin/bash

#chef-server-ctl stop
#hostn=$(cat /etc/hostname)
#sudo sed -i "s/$hostn/dcos-api/g" /etc/hostname
#hostname dcos-api
#chef-server-ctl start

# Create chef-server.rb with variables
echo "nginx['enable_non_ssl']=false" > /etc/opscode/chef-server.rb

if [[ -z $SSL_PORT ]]; then
  echo "nginx['ssl_port']=443" >> /etc/opscode/chef-server.rb
else
  echo "nginx['ssl_port']=$SSL_PORT" >> /etc/opscode/chef-server.rb
fi

if [[ -z $CONTAINER_NAME ]]; then
  echo "nginx['server_name']=\"chef-server\"" >> /etc/opscode/chef-server.rb
else
  echo "nginx['server_name']=\"$CONTAINER_NAME\"" >> /etc/opscode/chef-server.rb
fi

echo -e "\nRunning: 'chef-server-ctl reconfigure'. This step will take a few minutes..."
chef-server-ctl reconfigure

URL="http://127.0.0.1:8000/_status"
CODE=1
SECONDS=0
TIMEOUT=60

return=$(curl -sf ${URL})

if [[ -z "$return" ]]; then
  echo -e "\nINFO: Chef-Server isn't ready yet!"
  echo -e "Blocking until <${URL}> responds...\n"

  while [ $CODE -ne 0 ]; do

    curl -sf \
         --connect-timeout 3 \
         --max-time 5 \
         --fail \
         --silent \
         ${URL}

    CODE=$?

    sleep 2
    echo -n "."

    if [ $SECONDS -ge $TIMEOUT ]; then
      echo "$URL is not available after $SECONDS seconds...stopping the script!"
      exit 1
    fi
  done;
fi

#hostname dcos-api
cp knife.rb /etc/chef
curl https://packages.chef.io/files/stable/chefdk/2.3.4/ubuntu/14.04/chefdk_2.3.4-1_amd64.deb -O --insecure && dpkg -i chefdk_2.3.4-1_amd64.deb
cd /etc/chef;knife ssl fetch
echo -e "\n\n$URL is available!\n"
echo -e "\nSetting up admin user and default organization"
chef-server-ctl user-create trosadmin tros sktelecom trosadmin@admin.com "cloud000@"  --filename /etc/chef/trosadmin.pem
chef-server-ctl org-create trosadmin-org "trosSktelecomOrg" --association_user trosadmin --filename /etc/chef/trosadmin-org-validator.pem
echo -e "\nRunning: 'chef-server-ctl install chef-manage'"...
chef-server-ctl install opscode-push-jobs-server
chef-server-ctl install chef-manage
echo -e "\nRunning: 'chef-server-ctl reconfigure'"...
chef-server-ctl reconfigure
opscode-push-jobs-server-ctl reconfigure
echo "{ \"error\": \"Please use https:// instead of http:// !\" }" > /var/opt/opscode/nginx/html/500.json
sed -i "s,/503.json;,/503.json;\n    error_page 497 =503 /500.json;,g" /var/opt/opscode/nginx/etc/chef_https_lb.conf
sed -i '$i\    location /knife_admin_key.tar.gz {\n      default_type application/zip;\n      alias /etc/chef/knife_admin_key.tar.gz;\n    }' /var/opt/opscode/nginx/etc/chef_https_lb.conf
echo -e "\nCreating tar file with the Knife keys"
cd /etc/chef/ && tar -cvzf knife_admin_key.tar.gz admin.pem my_org-validator.pem
echo -e "\nRestart Nginx..."
chef-server-ctl restart nginx
chef-server-ctl status
touch /root/chef_configured
echo -e "\n\nDone!\n"

#chef-manage-ctl reconfigure --accept-license
