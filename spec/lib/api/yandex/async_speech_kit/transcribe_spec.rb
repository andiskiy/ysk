# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Yandex::AsyncSpeechKit::Transcribe do
  subject(:perform) { described_class.call(file_url: file_url) }

  before do
    stub_request(:post, "#{described_class::BASE_URL}#{path}")
      .with(body: request_body)
      .to_return(status: status, body: result.to_json)
  end

  let(:file_url) { Faker::Lorem.word }
  let(:path) { 'speech/stt/v2/longRunningRecognize' }
  let(:status) { 200 }
  let(:request_body) do
    {
      config: {
        specification: {
          languageCode: 'ru-RU'
        }
      },
      audio: {
        uri: file_url
      }
    }.to_json
  end

  let(:result) do
    {
      done: false,
      id: 'e03sup6d5h7rq574ht8g',
      createdAt: '2019-04-21T22:49:29Z',
      createdBy: 'ajes08feato88ehbbhqq',
      modifiedAt: '2019-04-21T22:49:29Z'
    }.as_json
  end

  it 'is success' do
    perform

    expect(perform.response_body).to eq(result)
  end

  context 'when response code is 422' do
    let(:status) { 422 }

    it { expect(perform).to be_failed }
  end

  context 'when file_url is blank' do
    let(:file_url) { '' }

    it { expect(perform).to be_failed }
  end
end
