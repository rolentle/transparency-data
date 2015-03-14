require File.dirname(__FILE__) + '/helper'

class TransparencyDataTest < Minitest::Test

  describe "when consuming the Sunlight Transparency Data API" do

    it "should set the API key on the module" do
      TransparencyData.configure do |config|
        config.api_key = CONFIG['key']
      end
      assert_equal TransparencyData.api_key, CONFIG['key']
    end

    it "provide helpers for URLs" do
      assert_equal TransparencyData.api_url("/contributions"), "#{TransparencyData.api_domain}/api/1.0/contributions.json"
    end

  end
end
