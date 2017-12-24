# chef-server

This is a modification of cbuisson/chef-server. I added chef browser and made it over docker-composea altogether. chef browser code was taken from 3ofcoins/chef-browser.

docker-compose 설치 
               
            
먼저 docker와 docker-compose를 설치한다.
docker-compose는 다음과 같이 설치한다.(https://docs.docker.com/compose/install/#install-compose)
docker compose를 다운로드한다. 
sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

docker-compose의 permission을 변경한다.
sudo chmod +x /usr/local/bin/docker-compose
/usr/local/bin이 path에 빠졌다면, .bash_profile에 path를 추가한후, source 명령어를 실행한다.

설치가 잘 되었는지 확인한다.
docker-compose --version

chef-server build 및 run하기-Version 1
T-CORE 과제 Mgmt. > 25. Chef, Razor Containerization > image2017-12-6 10:24:59.png

아래의 docker-compose는 꼭 chef의 경우 chef-server라는 directory에서, razor는 razor-server라는 directory에서 실행해야 한다. 그 이유는 container가 directory의 이름을 container의 이름 앞에 붙여서 사용하며, container 이름을 hostname으로 이용하여 접속하기 때문이다.

host machine에 사전에 /var/opt/opscode라는 directory를 root권한으로 생성한다. 이 directory는 chef-server container와 공유하는 volume이다. host machine에 사전에 directory를 생성하지 않고도, host에 container의 데이터를 저장하는 방법이 volume을 사용하는 것이다.
Chef Dockerfile 및 docker-compose.yml 이 다운로드된 directory에서 docker-compose up 명령어를 실행하면, 이미지가 build되면서 container가 실행된다. (docker-compose up 명령어로 이미지가 생성되지 않고, error가 발생하면 docker-compose build로 이미지를 생성후 다시 docker-compose run 명령어를 실행하면 된다.) docker-compose 명령어로 생성 후 실행되는 container 이름은 해당 directory 이름이 앞에 붙는다. 예를 들어, docker images 명령어로 확인 결과 chefserver_chef-server과 chefserver_chef-browser라는 이미지가 생성되었다면, chefserver는 chef Dockerfile 및 docker-compose.yml 파일이 있던 directory 이름이고, chef-server, chef-browser는 docker-compose.yml 파일에 정의된 서비스 이름이다. 마찬가지로, docker images 명령어로 docker ps 명령어로 확인 결과 chefserver_chef-server_1과 chefserver_chef-browser_1라는 container가 생성되었다면, chefserver는 chef Dockerfile 및 docker-compose.yml 파일이 있던 directory 이름이고, chef-server, chef-browser는 docker-compose.yml 파일에 정의된 서비스 이름이며, _1은 인스턴스가 생성될 때 붙는다.
docker-compose up 명령어를 실행 결과 Application efast_xs started on node 'erchef@127.0.0.1'이 출력되었으면 chef-server가 완전히 구동된 것이다.
docker ps로 확인한 chef-server container의 id를 확인하여 접속한다. 예) docker exec -it 53f /bin/bash  chef-sever container에는 knife도 설치되어 있으며, /etc/chef에 knife.rb 파일이 있어서 여기서 명령어를 실행하면 된다.
/etc/chef로 이동하여(cd /etc/chef) trosadmin.pem과 trosadmin-org-validator.pem 파일의 내용을 복사한다.
docker ps로 확인한 chef-browser container의 id를 확인하여 접속한다. 이 때는 옵션으로 -u 0를 사용하여 root 권한으로 접속한다. 그 이유는 chef-browser가 root가 아닌 www-data라는 계정으로 실행되기 때문이다. 예) docker exec -u 0 -it f45 /bin/bash
/opt/chef-browser/features/fixtures로 이동한다. cd features/fixtures
여기에, trosadmin.pem과 trosadmin-org-validator.pem 파일의 내용을 동일한 이름의 파일로 저장한 후, http://chef-server(또는 localhost 등):9292로 접속하여 chef-server가 동작하는 것을 확인한다. chef-server가 configure_chef.sh와 run.sh를 실행하는데, 몇 분 걸리기 때문에 그 동안 접속하면 http 에러가 발생한다는 것 참고하시기 바랍니다.
      첨부 파일: chef-server.zip 



chef-server build 및 run하기-Version 2
 
위의 'chef-server build 및 run하기-Version 1'에서는 chef-server에서 생성된 인증서(trosadmin.pem과 trosadmin-org-validator.pem)를 복사하여 chef-browser에 저장하였는데, Version 2에서는 이런 절차없이 자동으로 복사 및 저장되도록 하였다. 이는 docker-compose의 shared volume을 사용하여 구현하였다. Version 1과 마찬가지로, chef-server가 configure_chef.sh와 run.sh를 실행하는데, 몇 분 걸리기 때문에 그 동안 접속하면 http 에러가 발생한다는 것 참고하시기 바랍니다.

version: '3'
services:
chef-server:
build:
context: .
dockerfile: Dockerfile
command: /usr/local/bin/run.sh
volumes:
- chef-server:/var/opt/opscode
- chef-server-certificate:/etc/chef
networks:
- default
ports:
- 443:443
privileged: true

chef-browser:
build:
context: ./chef-browser
dockerfile: Dockerfile
networks:
- default
ports:
- 9292:9292
volumes:
- chef-server-certificate:/opt/chef-browser/features/fixtures

volumes:
chef-server:
chef-server-certificate:

첨부 파일: chef-server-1.zip



혹시 run.sh 관련 에러가 발생할 경우에는 첨부된 Dockerfile의 내용에 아래와 같이 붉은색 부분 RUN을 추가하고, CMD를 변경하세요.



[root@d-ttro-os42 chef-server]# cat Dockerfile
FROM ubuntu:14.04
MAINTAINER Clement Buisson <clement.buisson@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /opt/chef-browser
ADD chef-browser /opt/chef-browser
ADD knife.rb /

RUN apt-get update && \
apt-get install -yq --no-install-recommends wget curl rsync && \
wget --no-check-certificate --content-disposition "http://www.opscode.com/chef/download-server?p=ubuntu&pv=14.04&m=x86_64&v=12&prerelease=false&nightlies=false" && \
dpkg -i chef-server*.deb && \
rm chef-server*.deb && \
apt-get remove -y wget && \
rm -rf /var/lib/apt/lists/*
COPY run.sh configure_chef.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*
VOLUME /var/log
CMD ["/usr/local/bin/run.sh"]

------------------------------------------------------------------------------

chef-server will run Chef Server 12 in an Ubuntu Trusty 14.04 LTS container.  
Image Size: Approximately 1GB

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
##### Protocol / Port
Chef is running over HTTPS/443 by default.  
You can however change that to another port by adding `-e SSL_PORT=new_port` to the `docker run` command below and update the expose port `-p` accordingly.

##### SSL certificate
When Chef Server gets configured it creates an SSL certificate based on the container's FQDN (i.e "103d6875c1c5" which is the "CONTAINER ID"). This default behiavior has been changed to always produce an SSL certificate file named "chef-server.crt".  
You can change the certificate name by adding  `-e CONTAINER_NAME=new_name` to the `docker run` command. Remember to reflect that change in config.rb!

##### Logs
`/var/log/` is accessible via a volume directory. Feel free to optionally to use it with the `docker run` command above by adding: `-v ~/chef-logs:/var/log`

##### DNS
The container needs to be **DNS resolvable!**  
Be sure **'chef-server'** or **$CONTAINER_NAME** is pointing to the container's IP!  
This needs to be done to match the SSL certificate name with the `chef_server_url ` from knife's `config.rb` file.

## Start the container
Docker command:

```bash
$ docker run --privileged -t --name chef-server -d -p 443:443 cbuisson/chef-server
```

Follow the installation:

```bash
$ docker logs -f chef-server
```

## Setup knife

Once Chef Server 12 is configured, you can download the Knife admin keys here:

```bash
curl -Ok https://chef-server:$SSL_PORT/knife_admin_key.tar.gz
```

Then un-tar that archive and point your config.rb to the `admin.pem` and `my_org-validator.pem` files.

*config.rb* example:

```ruby
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '/home/cbuisson/.chef/admin.pem'
validation_client_name   'my_org-validator'
validation_key           '/home/cbuisson/.chef/my_org-validator.pem'
chef_server_url          'https://chef-server:$SSL_PORT/organizations/my_org'
```

When the config.rb file is ready, you will need to get the SSL certificate file from the container to access Chef Server:

```bash
cbuisson@server:~/.chef# knife ssl fetch
WARNING: Certificates from chef-server will be fetched and placed in your trusted_cert
directory (/home/cbuisson/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for chef-server in /home/cbuisson/.chef/trusted_certs/chef-server.crt
```

You should now be able to use the knife command!
```bash
cbuisson@server:~# knife user list
admin
```
**Done!**

##### Note
Chef-Server running inside a container isn't officially supported by [Chef](https://www.chef.io/about/) and as a result the webui isn't available.  
However the webui is not required since you can interact with Chef-Server via the `knife` and `chef-server-ctl` commands.

##### Tags
v1.0: Chef Server 11  
v2.x: Chef Server 12
# chef-server
