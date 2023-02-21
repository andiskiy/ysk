# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Yandex::RefreshIamToken do
  subject(:perform) { described_class.call }

  before do
    stub_request(:post, "#{described_class::BASE_URL}iam/v1/tokens")
      .with(body: request_body.to_json)
      .to_return(status: status, body: result.to_json)
  end

  let(:request_body) { { 'yandexPassportOauthToken' => ENV['YANDEX_OAUTH_TOKEN'] } }
  let(:status) { 200 }

  let(:result) do
    {
      'iamToken' => Faker::Lorem.word,
      'expiresAt' => '2023-02-22T08:18:06.405636358Z'
    }
  end

  context 'when token expired' do
    it 'is success' do
      perform

      expect(Auth.token).to eq(result['iamToken'])
    end
  end

  context 'when response code is 422' do
    let(:status) { 422 }
    let(:token) { Faker::Lorem.word }

    before { Auth.instance.update(token: token) }

    it 'is failed' do
      expect(perform).to be_failed
      expect(Auth.token).to eq(token)
    end
  end
end
