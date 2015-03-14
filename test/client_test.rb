require File.dirname(__FILE__) + '/helper'

class ClientTest < Minitest::Test

  describe "when using Client" do

    describe "when handling parameters" do

      it "map arrays to delimited text" do
        scenarios = [
          [{:date => "2009-03-04"},  {:date => "2009-03-04"}],
          [{:date => ["2009-03-04", "2009-03-06"]}, {:date => "2009-03-04|2009-03-06"}],
          [{:date => {:between => ["2009-03-04", "2009-03-06"] } }, {:date => "><|2009-03-04|2009-03-06"}],
          [{:date => {:gte => "2009-03-04"} }, {:date => ">|2009-03-04"}],
          [{:date => {:lte => "2009-03-04"} }, {:date => "<|2009-03-04"}]
        ]
        scenarios.each do |original, prepared|
          assert_equal TransparencyData::Client.prepare_params(original), prepared
        end
      end

      it "remove problematic characters" do
        assert_equal TransparencyData::Client.prepare_params({:search => "Yahoo!"}), {:search => "Yahoo"}
      end
    end

    describe "when searching contributions" do
      it "return a list" do
        VCR.use_cassette('contributions') do
          contributions = TransparencyData::Client.contributions(:contributor_ft => 'steve jobs')
          assert_equal contributions.class, Array
          assert contributions.first.has_key?("amount")
        end
      end

      it "find all the money Steve Jobs gave between March 3rd and March 10th 2009" do
        VCR.use_cassette('contributions in date range') do
          contributions = TransparencyData::Client.contributions(:contributor_ft => 'steve jobs', :date => {:between => ["2009-03-04", "2009-03-10"]})
          assert_equal contributions.class, Array
        end
      end
    end

    describe "when searching lobbyists" do
      it "return a list of lobbying events" do
        VCR.use_cassette('lobbying events') do
          lobbying = TransparencyData::Client.lobbying(:client_ft => "apple inc")
          assert_equal lobbying.class, Array
        end
      end
    end

    describe "when searching entities" do
      it "return a list of entities" do
        VCR.use_cassette('entities') do
          entities = TransparencyData::Client.entities(:search => "nancy pelosi")
          assert_equal entities.class, Array
        end
      end
    end

    describe "when looking up by entity ids" do
      it "return a list of entity ids" do
        VCR.use_cassette('entity ids') do
          entity_ids = TransparencyData::Client.id_lookup(:namespace => "urn:crp:recipient", :id => "N00007360")
          assert_kind_of Array, entity_ids
        end
      end
    end

    describe "when getting one entity" do
      before do
        VCR.use_cassette('politician id') do
          entities = TransparencyData::Client.entities(:search => "nancy pelosi")
          entities.each { |entity| @pelosi_id = entity.id if entity['type'] == "politician" }
        end
      end

      it "return an entity" do
        VCR.use_cassette('entity') do
          entity = TransparencyData::Client.entity(@pelosi_id)
          assert_equal entity.name, "Nancy Pelosi (D)"
        end
      end
    end

    # describe "politician methods" do
    #   before do
    #     entities = TransparencyData::Client.entities(:search => "nancy pelosi")
    #     entities.each do |entity|
    #       @pelosi_id = entity.id if entity['type'] == "politician"
    #     end
    #   end

    #   it "return a list of top contributors" do
    #     VCR.use_cassette('top contributors') do
    #       contributors = TransparencyData::Client.top_contributors(@pelosi_id)
    #       assert_equal contributors.class, Array
    #       assert_equal contributors.length, 10
    #     end
    #   end

    #   it "return a list of 5 top contributors" do
    #     VCR.use_cassette('top 5 contributors') do
    #       contributors = TransparencyData::Client.top_contributors(@pelosi_id, :limit => 5)
    #       assert_equal contributors.class, Array
    #       assert_equal contributors.length, 5
    #     end
    #   end

    #   it "return a list of top sectors" do
    #     VCR.use_cassette('top sectors') do
    #       sectors = TransparencyData::Client.top_sectors(@pelosi_id)
    #       assert_equal sectors.class, Array
    #       assert_equal sectors.first.name.class, String
    #     end
    #   end

    #   it "return a list of top industries within sector" do
    #     VCR.use_cassette('top industries within sector') do
    #       industries = TransparencyData::Client.top_industries(@pelosi_id,"F")
    #       assert_equal industries.class, Array
    #       assert_equal industries.first.count.class, Fixnum
    #     end
    #   end

    #   it "return a local breakdown" do
    #     VCR.use_cassette('local breakdown') do
    #       local_breakdown = TransparencyData::Client.local_breakdown(@pelosi_id)
    #       assert_equal local_breakdown.in_state_amount.class, Float
    #     end
    #   end

    #   it "return a contributor type breakdown" do
    #     VCR.use_cassette('contributor type breakdown') do
    #       local_breakdown = TransparencyData::Client.contributor_type_breakdown(@pelosi_id)
    #       assert_equal local_breakdown.individual_count, local_breakdown["Individuals"][0]
    #     end
    #   end

    # end

    # describe "individual (contributor) methods" do

    #   before do
    #     entities = TransparencyData::Client.entities(:search => "boone pickens")
    #     entities.each do |entity|
    #       @boone_id = entity.id if entity['type'] == "individual"
    #     end
    #   end

    #   it "return a list of top recipient organizations" do
    #     VCR.use_cassette('top recipient organizations') do
    #       recipient_orgs = TransparencyData::Client.top_recipient_orgs(@boone_id)
    #       assert_equal recipient_orgs.class, Array
    #       assert_equal recipient_orgs.length, 10
    #     end
    #   end

    #   it "return a list of top recipient politicians" do
    #     VCR.use_cassette('top recipient politicians') do
    #       recipient_pols = TransparencyData::Client.top_recipient_pols(@boone_id)
    #       assert_equal recipient_pols.class, Array
    #       assert_equal recipient_pols.length, 10
    #     end
    #   end

    #   it "return a party breakdown" do
    #     VCR.use_cassette('individual party breakdown') do
    #       party_breakdown = TransparencyData::Client.individual_party_breakdown(@boone_id)
    #       assert_equal party_breakdown.dem_count, party_breakdown["Democrats"][0]
    #     end
    #   end

    # end

    # describe "organization methods" do

    #   before do
    #     entities = TransparencyData::Client.entities(:search => "wal-mart")
    #     entities.each do |entity|
    #       @walmart_id = entity.id if entity['type'] == "organization"
    #     end
    #   end

    #   it "return a list of top organization recipients" do
    #     VCR.use_cassette('top org recipients') do
    #       org_recipients = TransparencyData::Client.top_org_recipients(@walmart_id)
    #       assert_equal org_recipients.class, Array
    #       assert_equal org_recipients.length, 10
    #     end
    #   end

    #   it "return a party breakdown" do
    #     VCR.use_cassette('org party breakdown') do
    #       party_breakdown = TransparencyData::Client.org_party_breakdown(@walmart_id)
    #       assert_equal party_breakdown.dem_count, party_breakdown["Democrats"][0]
    #     end
    #   end

    #   it "return a state/federal level breakdown" do
    #     VCR.use_cassette('org level breakdown') do
    #       level_breakdown = TransparencyData::Client.org_level_breakdown(@walmart_id)
    #       assert_equal level_breakdown.federal_count, level_breakdown["Federal"][0]
    #     end
    #   end

    # end

    # describe "recipient methods" do

    #   before do
    #     boone = TransparencyData::Client.entities(:search => "t boone pickens")
    #     boone.each do |entity|
    #       @boone_id = entity.id if entity['type'] == "individual"
    #     end
    #     ted = TransparencyData::Client.entities(:search => "ted stevens")
    #     ted.each do |entity|
    #       @stevens_id = entity.id if entity['type'] == "politician"
    #     end
    #   end

    #   it "return a contributor summary" do
    #     VCR.use_cassette('recipient contributor summary') do
    #       summary = TransparencyData::Client.recipient_contributor_summary(@stevens_id, @boone_id)
    #       assert_equal summary.amount.class, Fixnum
    #     end
    #   end

    # end

  end

end
