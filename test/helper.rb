require 'test/unit'
require 'pathname'

require 'shoulda'
require 'matchy'
require 'mocha'
require 'fakeweb'
require 'vcr'

require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'transparency_data'
api_config = YAML.load_file(File.dirname(__FILE__) + '/../api.yml')
TransparencyData.api_key = api_config['key']
TransparencyData.api_domain = api_config['domain'] if api_config['domain']

#FakeWeb.allow_net_connect = false

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { :record => :new_episodes }
end
