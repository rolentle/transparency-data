module TransparencyData
  class Client
    def self.get_response(endpoint:, params: nil)
      conn = Faraday.new(url: TransparencyData.api_domain)
      endpoint = TransparencyData.api_endpoint(endpoint)
      url_params = if params
                     prepare_params(params).merge(apikey: TransparencyData.api_key)
                   else
                     { apikey: TransparencyData.api_key }
                   end
      conn.get(endpoint, url_params)
    end

    def self.contributions(params)
      response = get_response(endpoint: "/contributions", params: params)
      handle_response(response)
    end

    def self.lobbying(params)
      response = get_response(endpoint: "/lobbying", params: params)
      handle_response(response)
    end

    def self.entities(params)
      response = get_response(endpoint: "/entities", params: params)
      handle_response(response)
    end

    def self.id_lookup(params)
      response = get_response(endpoint: "/entities/id_lookup", params: params)
      handle_response(response)
    end

    def self.entity(id, params=nil)
      response = get_response(endpoint: "/entities/#{id}", params: params)
      Hashie::Mash.new(JSON.parse(response.body))
    end

    def self.top_contributors(id, params=nil)
      response = get_response(endpoint: "/aggregates/pol/#{id}/contributors", params: params)
      handle_response(response)
    end

    def self.top_sectors(id, params=nil)
      response = get_response(endpoint: "/aggregates/pol/#{id}/contributors/sectors", params: params)
      sectors = handle_response(response)
      TransparencyData::Client.process_sectors(sectors)
    end

    def self.top_industries(id, sector, params=nil)
      response = get_response(endpoint: "/aggregates/pol/#{id}/contributors/industries", params: params)
      handle_response(response)
    end

    def self.local_breakdown(id, params=nil)
      response = get_response(endpoint: "/aggregates/pol/#{id}/contributors/local_breakdown", params: params)
      breakdown = Hashie::Mash.new(JSON.parse(response.body))
      process_local_breakdown(breakdown)
    end

    def self.contributor_type_breakdown(id, params=nil)
      response = get_response(endpoint: "/aggregates/pol/#{id}/contributors/type_breakdown", params: params)
      breakdown = Hashie::Mash.new(JSON.parse(response.body))
      process_contributor_type_breakdown(breakdown)
    end

    def self.top_recipient_orgs(id, params=nil)
      response = get_response(endpoint: "/aggregates/indiv/#{id}/recipient_orgs", params: params)
      handle_response(response)
    end

    def self.top_recipient_pols(id, params=nil)
      response = get_response(endpoint: "/aggregates/indiv/#{id}/recipient_pols", params: params)
      handle_response(response)
    end

    def self.individual_party_breakdown(id, params=nil)
      response = get_response(endpoint: "/aggregates/indiv/#{id}/recipients/party_breakdown", params: params)
      breakdown = Hashie::Mash.new(JSON.parse(response.body))
      process_party_breakdown(breakdown)
    end

    def self.top_org_recipients(id, params=nil)
      response = get_response(endpoint: "/aggregates/org/#{id}/recipients", params: params)
      handle_response(response)
    end

    def self.org_party_breakdown(id, params=nil)
      response = get_response(endpoint: "/aggregates/org/#{id}/recipients/party_breakdown", params: params)
      breakdown = Hashie::Mash.new(JSON.parse(response.body))
      process_org_party_breakdown(breakdown)
    end

    def self.org_level_breakdown(id, params=nil)
      response = get_response(endpoint: "/aggregates/org/#{id}/recipients/level_breakdown", params: params)
      breakdown = Hashie::Mash.new(JSON.parse(response.body))
      process_org_level_breakdown(breakdown)
    end

    def self.recipient_contributor_summary(recipient_id, contributor_id, params=nil)
      #TODO: is endpoint deprecated?"
      response = get_response(endpoint: "/aggregates/recipient/#{recipient_id}/contributor/#{contributor_id}/amount", params: params)
      Hashie::Mash.new(JSON.parse(response.body))
    end

    def self.prepare_params(params)
      params.each do |key, value|
        if value.is_a?(Hash)
          case value.keys.first
          when :gte
            params[key] = ">|#{value.values.first}"
          when :lte
            params[key] = "<|#{value.values.first}"
          when :between
            params[key] = "><|#{value.values.first.join('|')}"
          end
        elsif value.is_a?(Array)
          params[key] = value.join("|")
        elsif value.is_a?(String)
          params[key] = value.sub(/[\*\?!=&%]/,'')
        end
      end
      params
    end

    def self.handle_response(response)
      # TODO: raise_errors
      JSON.parse(response.body).map {|c| Hashie::Mash.new(c)}
    end

    def self.process_sectors(sectors)
      sectors.each do |sector|
        sector["name"] = case sector.sector
                         when "A" then "Agribusiness"
                         when "B" then "Communications/Electronics"
                         when "C" then "Construction"
                         when "D" then "Defense"
                         when "E" then "Energy/Natural Resources"
                         when "F" then "Finance/Insurance/Real Estate"
                         when "H" then "Health"
                         when "K" then "Lawyers/Lobbyists"
                         when "M" then "Transportation"
                         when "N" then "Misc. Business"
                         when "Q" then "Ideology/Single Issue"
                         when "P" then "Labor"
                         when "W" then "Other"
                         when "Y" then "Unknown"
                         when "Z" then "Administrative Use"
                         end
      end
    end

      def self.process_local_breakdown(breakdown)
        TransparencyData::Client.mashize_key(breakdown, "in-state", "in_state")
        TransparencyData::Client.mashize_key(breakdown, "out-of-state", "out_of_state")
        TransparencyData::Client.mashize_key(breakdown, "In-State", "in_state")
        TransparencyData::Client.mashize_key(breakdown, "Out-of-State", "out_of_state")
        breakdown
      end

      def self.process_contributor_type_breakdown(breakdown)
        TransparencyData::Client.mashize_key(breakdown, "Individuals", "individual")
        TransparencyData::Client.mashize_key(breakdown, "PACs", "pac")
        breakdown
      end

      def self.process_party_breakdown(breakdown)
        TransparencyData::Client.mashize_key(breakdown, "Democrats", "dem")
        TransparencyData::Client.mashize_key(breakdown, "Republicans", "rep")
        TransparencyData::Client.mashize_key(breakdown, "L", "lib")
        TransparencyData::Client.mashize_key(breakdown, "I", "ind")
        TransparencyData::Client.mashize_key(breakdown, "U", "unknown")
        TransparencyData::Client.mashize_key(breakdown, "Other", "other")
        TransparencyData::Client.mashize_key(breakdown, "3", "third")
        breakdown
      end

      def self.process_org_party_breakdown(breakdown)
        TransparencyData::Client.mashize_key(breakdown, "Democrats", "dem")
        TransparencyData::Client.mashize_key(breakdown, "Republicans", "rep")
        TransparencyData::Client.mashize_key(breakdown, "L", "lib")
        TransparencyData::Client.mashize_key(breakdown, "I", "ind")
        TransparencyData::Client.mashize_key(breakdown, "U", "unknown")
        TransparencyData::Client.mashize_key(breakdown, "Other", "other")
        TransparencyData::Client.mashize_key(breakdown, "3", "third")
        breakdown
      end

      def self.process_org_level_breakdown(breakdown)
        TransparencyData::Client.mashize_key(breakdown, "State", "state")
        TransparencyData::Client.mashize_key(breakdown, "Federal", "federal")
        breakdown
      end

      def self.mashize_key(breakdown, api_key, mash_key)
        if breakdown[api_key]
          breakdown["#{mash_key}_count"]  = breakdown[api_key][0].to_i
          breakdown["#{mash_key}_amount"] = breakdown[api_key][1].to_f
        end
      end
  end
end
