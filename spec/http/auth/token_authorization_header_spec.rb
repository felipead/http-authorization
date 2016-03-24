require 'http/auth'

include HTTP::Auth

describe TokenAuthorizationHeader do
  describe 'given a complete token authorization header' do
    let :complete_header_with_extra_whitespaces do
      <<-EOS
        token="5ccc069c403ebaf9f0171e9517f40e41",
        coverage="foobar",
        nonce="2e0d73708933eff3e53319d884a0505c",
        auth="ed5a137d3724ec12ddd95bbea3e8a634",
        timestamp="1458771255"
      EOS
    end

    let :complete_header do
      complete_header_with_extra_whitespaces.gsub(/\s+/, ' ').strip
    end

    it 'successfully parses the header string' do
      parsed = TokenAuthorizationHeader.parse(complete_header)
      expect(parsed.schema).to eq(:token)
      expect(parsed.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
      expect(parsed.coverage).to eq('foobar')
      expect(parsed.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
      expect(parsed.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
      expect(parsed.timestamp).to eq('1458771255')
    end

    it 'successfully parses the header string regardless of extra whitespace' do
      parsed = TokenAuthorizationHeader.parse(complete_header_with_extra_whitespaces)
      expect(parsed.schema).to eq(:token)
      expect(parsed.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
      expect(parsed.coverage).to eq('foobar')
      expect(parsed.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
      expect(parsed.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
      expect(parsed.timestamp).to eq('1458771255')
    end

    it 'builds the header string' do
      parsed = TokenAuthorizationHeader.parse(complete_header)
      expect(parsed.to_s).to eq("Token #{complete_header}")
    end
  end

  describe 'given an incomplete token authorization header' do
    describe 'parsing the header string' do
      it 'fails if "token" is ommited' do
        without_token = 'coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
        expect do
          TokenAuthorizationHeader.parse without_token
        end.to raise_error(ArgumentError).with_message('Token attribute is required')
      end

      it 'fails if "token" is empty' do
        with_empty_token = 'token="", coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
        expect do
          TokenAuthorizationHeader.parse with_empty_token
        end.to raise_error(ArgumentError).with_message('Token attribute is required')
      end

      it 'returns "base" if "coverage" is ommited' do
        without_coverage = 'token="sample_token"'
        header = TokenAuthorizationHeader.parse without_coverage
        expect(header.coverage).to eq('base')
      end

      it 'returns "base" if "coverage" is empty' do
        with_empty_coverage = 'token="sample_token", coverage=""'
        header = TokenAuthorizationHeader.parse with_empty_coverage
        expect(header.coverage).to eq('base')
      end

      it 'returns nil if "nonce" is ommited' do
        without_nonce = 'token="sample_token"'
        header = TokenAuthorizationHeader.parse without_nonce
        expect(header.nonce).to be_nil
      end

      it 'returns nil if "auth" is ommited' do
        without_auth = 'token="sample_token"'
        header = TokenAuthorizationHeader.parse without_auth
        expect(header.auth).to be_nil
      end

      it 'returns nil if "timestamp" is ommited' do
        without_timestamp = 'token="sample_token"'
        header = TokenAuthorizationHeader.parse without_timestamp
        expect(header.timestamp).to be_nil
      end
    end

    describe 'building the header string' do
      it 'builds with default "coverage"' do
        header = TokenAuthorizationHeader.new(
          token: 'sample_token',
          nonce: 'sample_nonce',
          auth: 'sample_auth',
          timestamp: '123456789'
        )
        header_string = header.to_s
        expect(header_string).to include('coverage="base"')
        expect(header_string).to include('token=')
        expect(header_string).to include('nonce=')
        expect(header_string).to include('auth=')
        expect(header_string).to include('timestamp=')
      end

      it 'builds without "nonce"' do
        header = TokenAuthorizationHeader.new(
          token: 'sample_token',
          coverage: 'sample_coverage',
          auth: 'sample_auth',
          timestamp: '123456789'
        )
        header_string = header.to_s
        expect(header_string).to_not include('nonce=')
        expect(header_string).to include('token=')
        expect(header_string).to include('coverage=')
        expect(header_string).to include('auth=')
        expect(header_string).to include('timestamp=')
      end

      it 'builds without "auth"' do
        header = TokenAuthorizationHeader.new(
          token: 'sample_token',
          coverage: 'sample_coverage',
          nonce: 'sample_nonce',
          timestamp: '123456789'
        )
        header_string = header.to_s
        expect(header_string).to_not include('auth=')
        expect(header_string).to include('token=')
        expect(header_string).to include('coverage=')
        expect(header_string).to include('nonce=')
        expect(header_string).to include('timestamp=')
      end

      it 'builds without "timestamp"' do
        header = TokenAuthorizationHeader.new(
          token: 'sample_token',
          coverage: 'sample_coverage',
          nonce: 'sample_nonce',
          auth: 'sample_auth'
        )
        header_string = header.to_s
        expect(header_string).to_not include('timestamp=')
        expect(header_string).to include('token=')
        expect(header_string).to include('coverage=')
        expect(header_string).to include('nonce=')
        expect(header_string).to include('auth=')
      end
    end
  end
end
