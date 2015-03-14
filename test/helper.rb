gem 'minitest'
require 'minitest/autorun'
require 'yaml'
require 'pathname'

require 'shoulda'
require 'mocha'
require 'vcr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'transparency_data'
CONFIG = YAML.load_file(File.dirname(__FILE__) + '/../api.yml')
TransparencyData.api_key = CONFIG['key']
TransparencyData.api_domain = CONFIG['domain'] if CONFIG['domain']

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { :record => :new_episodes }
end
