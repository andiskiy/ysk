# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Audio::RecognizeService do
  subject(:call_service) { described_class.call(params) }

  let(:params) do
    {
      chat_id: chat_id,
      file_id: file_id,
      message_id: message_id
    }
  end
  let(:chat_id) { Faker::Number.number }
  let(:file_id) { Faker::Lorem.word }
  let(:message_id) { Faker::Number.number }
  let(:file_path) { 'voice/file_2.oga' }
  let(:get_file_response) do
    {
      'ok' => true,
      'result' => {
        'file_id' => file_id,
        'file_path' => file_path,
        'file_unique_id' => Faker::Lorem.word
      }
    }
  end

  before do
    allow(::Api::Telegram::DownloadFile).to receive(:call).with(file_path: file_path)
    allow(Telegram.bot).to receive(:get_file).with(file_id: file_id).and_return(get_file_response)
  end

  it { expect(call_service).to be_success }

  context 'when chat_id is nil' do
    let(:chat_id) { nil }

    it { expect(call_service).to be_failed }
  end

  context 'when file_id is blank' do
    let(:file_id) { '' }

    it { expect(call_service).to be_failed }
  end

  context 'when message_id is nil' do
    let(:message_id) { nil }

    it { expect(call_service).to be_failed }
  end
end
