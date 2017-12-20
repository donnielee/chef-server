server_url "http://chefserver_chef-server_1:#{::ENV['CHEF_ZERO_PORT']}"
#server_url "http://dcos-api:#{::ENV['CHEF_ZERO_PORT']}"
client_name "trosadmin"
client_key ::File.join(::File.dirname(__FILE__), 'trosadmin.pem')
node_search['Database tag'] = 'tags:db'
