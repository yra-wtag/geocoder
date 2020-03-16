require "geocoder/lookups/google"
require "geocoder/results/google_nearby_places"

module Geocoder
  module Lookup
    class GoogleNearbyPlacesSearch < Google
      def name
        "Google Nearby Places Search"
      end

      def required_api_key_parts
        ["key"]
      end

      def supported_protocols
        [:https]
      end

      def search(query, options = {})
        query = Geocoder::Query.new(query, options) unless query.is_a?(Geocoder::Query)
        api_output = results(query)
        {
          next_page: api_output["next_page_token"],
          results: api_output['results'].map{ |r|
            result = result_class.new(r)
            result.cache_hit = @cache_hit if cache
            result
          }
        }
      end

      private

      def base_query_url(query)
        "#{protocol}://maps.googleapis.com/maps/api/place/nearbysearch/json?"
      end

      def query_url_google_params(query)
        {
            location: query.text,
            radius: 50000,
            type: "lodging",
            language: query.language || configuration.language
        }
      end

      def results(query)
        return [] unless doc = fetch_data(query)
        case doc['status'];
        when "OK" # OK status implies >0 results
          return doc
        when "OVER_QUERY_LIMIT"
          raise_error(Geocoder::OverQueryLimitError) ||
              Geocoder.log(:warn, "#{name} API error: over query limit.")
        when "REQUEST_DENIED"
          raise_error(Geocoder::RequestDenied, doc['error_message']) ||
              Geocoder.log(:warn, "#{name} API error: request denied (#{doc['error_message']}).")
        when "INVALID_REQUEST"
          raise_error(Geocoder::InvalidRequest, doc['error_message']) ||
              Geocoder.log(:warn, "#{name} API error: invalid request (#{doc['error_message']}).")
        end
        return []
      end
    end
  end
end
