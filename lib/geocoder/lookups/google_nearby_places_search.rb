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
    end
  end
end
