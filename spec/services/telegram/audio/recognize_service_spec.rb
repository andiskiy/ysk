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
  let(:text) { 'result' }

  let(:send_message_params) do
    {
      chat_id: chat_id,
      text: text,
      reply_to_message_id: message_id
    }
  end

  let(:stub_download_file) do
    allow(::Telegram::Audio::DownloadService).to(
      receive(:call)
        .with(file_id: file_id)
        .and_return(Struct.new(:result, :failed?).new('response_body', d_f_failed_state)),
    )
  end

  let(:stub_speech_kit) do
    allow(::Api::Yandex::SpeechKit).to(
      receive(:call)
        .with(file: 'response_body')
        .and_return(
          Struct
            .new(:success?, :response_body)
            .new(speech_kit_success, { 'result' => text }),
        ),
    )
  end

  let(:stub_send_message) { allow(Telegram.bot).to receive(:send_message).with(send_message_params) }

  let(:d_f_failed_state) { false }
  let(:speech_kit_success) { true }

  context 'when everything is ok' do
    before do
      stub_download_file
      stub_speech_kit
      stub_send_message
    end

    it 'is success' do
      expect(call_service).to be_success
      expect(Telegram.bot).to have_received(:send_message).with(send_message_params)
    end
  end

  context 'when audio file not found' do
    before do
      stub_download_file
      stub_send_message
    end

    let(:text) { I18n.t('telegram.errors.invalid_audio_file') }
    let(:d_f_failed_state) { true }

    it 'is failed' do
      expect(call_service).to be_success
      expect(Telegram.bot).to have_received(:send_message).with(send_message_params)
    end
  end

  context 'when yandex speech api failed' do
    before do
      stub_download_file
      stub_speech_kit
      stub_send_message
    end

    let(:text) { I18n.t('telegram.errors.failed_recognize') }
    let(:speech_kit_success) { false }

    it 'is success' do
      expect(call_service).to be_success
      expect(Telegram.bot).to have_received(:send_message).with(send_message_params)
    end
  end

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
