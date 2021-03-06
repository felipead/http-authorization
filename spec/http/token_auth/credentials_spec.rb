require 'http/token_auth'

include HTTP::TokenAuth

describe Credentials do
  describe 'building an "Authentication" HTTP request header with the token scheme' do
    it 'fails if token is not defined' do
      expect do
        Credentials.new token: nil,
                        coverage: :base,
                        nonce: 'dj83hs9s',
                        auth: 'djosJKDKJSD8743243/jdk33klY=',
                        timestamp: 137131200
      end.to raise_error(CredentialsArgumentError).with_message('"token" is missing')
    end

    it 'fails if coverage is not "none", "base" or "base+body-sha-256"' do
      expect do
        Credentials.new token: 'h480djs93hd8',
                        coverage: :invalid,
                        nonce: 'dj83hs9s',
                        auth: 'djosJKDKJSD8743243/jdk33klY=',
                        timestamp: 137131200
      end.to raise_error(CredentialsArgumentError).with_message('unsupported "invalid" coverage')
    end

    describe 'using a cryptographic algorithm' do
      { 'base' => :base, 'base+body-sha-256' => :base_body_sha_256 }.each do |name, symbol|
        it %(builds it if coverage is "#{name}") do
          credentials = Credentials.new token: 'h480djs93hd8',
                                        coverage: symbol,
                                        nonce: 'dj83hs9s',
                                        auth: 'djosJKDKJSD8743243/jdk33klY=',
                                        timestamp: 137131200

          header = credentials.to_header
          expect(header).to start_with('Token')
          expect(header).to include('token="h480djs93hd8"')
          expect(header).to include(%(coverage="#{name}"))
          expect(header).to include('nonce="dj83hs9s"')
          expect(header).to include('auth="djosJKDKJSD8743243/jdk33klY="')
          expect(header).to include('timestamp="137131200"')
        end
      end

      it 'fails if nonce is not defined' do
        expect do
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          auth: 'djosJKDKJSD8743243/jdk33klY=',
                          timestamp: 137131200
        end.to raise_error(CredentialsArgumentError).with_message('"nonce" is missing')
      end

      it 'fails if auth is not defined' do
        expect do
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          nonce: 'dj83hs9s',
                          timestamp: 137131200
        end.to raise_error(CredentialsArgumentError).with_message('"auth" is missing')
      end

      it 'fails if timestamp is not defined' do
        expect do
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          nonce: 'dj83hs9s',
                          auth: 'djosJKDKJSD8743243/jdk33klY='
        end.to raise_error(CredentialsArgumentError).with_message('"timestamp" is missing')
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'builds it if coverage is "none", '\
         'without including "coverage", "nonce", "auth" and "timestamp" in the header string' do
        credentials = Credentials.new token: 'h480djs93hd8',
                                      coverage: :none

        header = credentials.to_header
        expect(header).to start_with('Token')
        expect(header).to include('token="h480djs93hd8"')
        expect(header).to_not include('coverage')
        expect(header).to_not include('nonce')
        expect(header).to_not include('auth')
        expect(header).to_not include('timestamp')
      end

      describe 'coverage' do
        it 'defaults to "none" if not defined' do
          credentials = Credentials.new token: 'h480djs93hd8'
          expect(credentials.coverage).to eq(:none)
        end

        it 'defaults to "none" if nil' do
          credentials = Credentials.new token: 'h480djs93hd8',
                                        coverage: nil
          expect(credentials.coverage).to eq(:none)
        end
      end
    end
  end
end
