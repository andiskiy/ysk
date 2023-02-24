# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Yandex::AsyncSpeechKit::Operation do
  subject(:perform) { described_class.call(operation_id: operation_id) }

  before do
    stub_request(:get, "#{described_class::BASE_URL}#{path}")
      .to_return(status: status, body: result.to_json)
  end

  let(:operation_id) { Faker::Number.number }
  let(:path) { "operations/#{operation_id}" }
  let(:status) { 200 }

  let(:result) do
    {
      done: true,
      response: {
        '@type': 'type.googleapis.com/yandex.cloud.ai.stt.v2.LongRunningRecognitionResponse',
        chunks: [
          {
            alternatives: [
              {
                words: [
                  {
                    startTime: '0.879999999s',
                    endTime: '1.159999992s',
                    word: 'при',
                    confidence: 1
                  },
                  {
                    startTime: '1.219999995s',
                    endTime: '1.539999988s',
                    word: 'написании',
                    confidence: 1
                  }
                ],
                text: 'при написании хоббита толкин обращался к мотивам '\
                      'скандинавской мифологии древней английской поэмы беовульф',
                confidence: 1
              }
            ],
            channelTag: '1'
          }
        ]
      },
      id: 'e03sup6d5h7rq574ht8g',
      createdAt: '2019-04-21T22:49:29Z',
      createdBy: 'ajes08feato88ehbbhqq',
      modifiedAt: '2019-04-21T22:49:36Z'
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

  context 'when operation_id is nil' do
    let(:operation_id) { nil }

    it { expect(perform).to be_failed }
  end
end
