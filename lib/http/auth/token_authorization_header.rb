module HTTP
  module Auth
    class TokenAuthorizationHeader
      attr_reader :token, :coverage, :nonce, :auth, :timestamp

      def initialize(attributes)
        @token = must_have_token(strip_whitespace(attributes[:token]))
        @coverage = must_have_coverage_or_default(strip_whitespace(attributes[:coverage]))
        @nonce = strip_whitespace(attributes[:nonce])
        @auth = strip_whitespace(attributes[:auth])
        @timestamp = strip_whitespace(attributes[:timestamp])
      end

      def schema
        :token
      end

      def self.parse(attributes_string)
        groups = extract_groups(attributes_string)
        TokenAuthorizationHeader.new extract_attributes(groups)
      end

      def to_s
        attributes = []
        attributes << %(token="#{@token}")
        attributes << %(coverage="#{@coverage}")
        attributes << %(nonce="#{@nonce}") if @nonce
        attributes << %(auth="#{@auth}") if @auth
        attributes << %(timestamp="#{@timestamp}") if @timestamp

        "Token #{attributes.join(', ')}"
      end

      private

      def must_have_token(token)
        raise ArgumentError, 'Token attribute is required' unless token && !token.empty?
        token
      end

      def must_have_coverage_or_default(coverage)
        (coverage && !coverage.empty?) ? coverage : 'base'
      end

      def strip_whitespace(string)
        string.nil? ? nil : string.strip
      end

      def self.extract_groups(attributes_string)
        attributes_string.scan(/(\w+)="([^"]*)"/)
      end

      def self.extract_attributes(groups)
        attributes = {}
        groups.each do |group|
          attributes[group[0].to_sym] = group[1]
        end
        attributes
      end

      private_class_method :extract_attributes, :extract_groups
    end
  end
end
