# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Yandex::SpeechKit::Transcribe do
  subject(:perform) { described_class.call(file: file) }

  before do
    stub_request(:post, "#{described_class::BASE_URL}#{path}")
      .with(body: file)
      .to_return(status: status, body: result.to_json)
  end

  let(:file) { Faker::Lorem.word }
  let(:path) { "speech/v1/stt:recognize?folderId=#{ENV['YANDEX_CLOUD_FOLDER_ID']}&lang=ru-RU" }
  let(:status) { 200 }

  let(:result) { { 'result' => 'how are you?' } }

  it 'is success' do
    perform

    expect(perform.response_body).to eq(result)
  end

  context 'when response code is 422' do
    let(:status) { 422 }

    it { expect(perform).to be_failed }
  end

  context 'when file is blank' do
    let(:file) { '' }

    it { expect(perform).to be_failed }
  end
end
