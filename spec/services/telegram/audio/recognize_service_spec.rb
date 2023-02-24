# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Audio::RecognizeService do
  subject(:call_service) { described_class.call(params) }

  let(:params) do
    {
      chat_id: chat_id,
      file_id: file_id,
      message_id: message_id,
      duration: duration
    }
  end
  let(:chat_id) { Faker::Number.number }
  let(:file_id) { Faker::Lorem.word }
  let(:message_id) { Faker::Number.number }
  let(:duration) { 10 }
  let(:text) { 'result' }

  let(:send_message_params) do
    {
      chat_id: chat_id,
      text: text,
      reply_to_message_id: message_id
    }
  end

  context 'when duration < 30' do
    context 'when everything is ok' do
      before do
        allow(::Yandex::SpeechKit::TranscribeService).to(
          receive(:call)
            .with(file_id: file_id)
            .and_return(
              Struct
                .new(:result)
                .new(text),
            ),
        )

        allow(::Telegram::Message::SendService).to(receive(:call).with(send_message_params))
      end

      it 'is success' do
        expect(call_service).to be_success
        expect(::Telegram::Message::SendService).to have_received(:call).with(send_message_params)
      end
    end


    context 'when duration >= 30' do
      let(:duration) { 31 }

      before { allow(::Yandex::AsyncSpeechKit::TranscribeService).to(receive(:call).with(params)) }

      it 'is failed' do
        expect(call_service).to be_success
        expect(::Yandex::AsyncSpeechKit::TranscribeService).to have_received(:call).with(params)
      end
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

  context 'when duration is nil' do
    let(:duration) { nil }

    it { expect(call_service).to be_failed }
  end
end
