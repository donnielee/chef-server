# -*- ruby -*-

server_url "https://chefserver_chef-server_1/organizations/trosadmin-org"
#server_url "https://dcos-api/organizations/trosadmin-org"
#server_url "https://192.168.41.132/organizations/trosadmin-org"
client_name "trosadmin"
client_key ::File.join(::File.dirname(__FILE__), 'features/fixtures/trosadmin.pem')

#server_url "http://127.0.0.1:4000"
#client_name "marta"
#client_key ::File.join(::File.dirname(__FILE__), 'features/fixtures/stub.pem')

# If the Chef server has a self-signed https certificate, SSL certificate
# checks need to be disabled.
#
connection[:ssl] = { verify: false }

# Save defined shortcuts to common node search queries like this:
#
# node_search['MySQL'] = 'mysql_server_root_password:*'

# Define the application's title like this:
#
# title "Chef Browser"

# Uncomment if you use chef below 11.0 or you don't want to
# use partial searches; they are used
# to make searches less heavy on memory and bandwidth
#
# use_partial_search false

# Uncomment if you use chef below 12.0 to enable login page
#
# login true

# Modify any of the details below
#
# cookie_secret ::SecureRandom.base64(64)
# cookie_time 3600
