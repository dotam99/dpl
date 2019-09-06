describe Dpl::Providers::Launchpad do
  let(:args) { %w(--slug ~user/project/branch --oauth_token token --oauth_token_secret secret) }
  let(:url)  { 'https://api.launchpad.net/1.0/~user/project/branch/+code-import' }
  let(:body) { 'ws.op=requestImport' }

  let(:auth) do
    /
      OAuth\ oauth_consumer_key="Travis%20Deploy",.*
      oauth_nonce=".*",.*
      oauth_signature="%26secret",.*
      oauth_signature_method="PLAINTEXT",.*
      oauth_timestamp=".*",.*
      oauth_token="token",.*
      oauth_version="1\.0"
    /x
  end

  before { stub_request(:post, /.*/) }
  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_requested(:post, url).with(body: body, headers: { Authorization: auth }) }
  end
end

