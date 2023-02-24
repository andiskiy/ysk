# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::AsyncSpeechKit::TranscribeService do
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
  let(:duration) { 10 }
  let(:message_id) { Faker::Number.number }
  let(:success_status) { true }
  let(:file_url) { Faker::Lorem.word }
  let(:worker_params) { [perform_worker_at, chat_id, message_id, yandex_api_result['id']] }
  let(:perform_worker_at) { ((duration / described_class::DIVISOR) + described_class::MEASUREMENT_ERROR).seconds }

  let(:yandex_api_result) do
    {
      done: false,
      id: 'e03sup6d5h7rq574ht8g',
      createdAt: '2019-04-21T22:49:29Z',
      createdBy: 'ajes08feato88ehbbhqq',
      modifiedAt: '2019-04-21T22:49:29Z'
    }.as_json
  end

  let(:tg_message_params) do
    {
      chat_id: chat_id,
      text: I18n.t('telegram.errors.failed_recognize'),
      reply_to_message_id: message_id
    }
  end

  before do
    allow(::Api::Yandex::AsyncSpeechKit::Transcribe).to(
      receive(:call)
        .with(file_url: file_url)
        .and_return(Struct.new(:success?, :response_body).new(success_status, yandex_api_result)),
    )

    allow(::Yandex::ObjectStorage::PutService).to(
      receive(:call)
        .with(file_id: file_id)
        .and_return(Struct.new(:result).new(file_url)),
    )

    allow(::Telegram::Message::SendService).to receive(:call).with(tg_message_params)

    allow(::Yandex::AsyncSpeechKit::OperationWorker).to(
      receive(:perform_in)
        .with(*worker_params),
    )
  end

  context 'when yandex api success' do
    it 'is success' do
      expect(call_service).to be_success
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::ObjectStorage::PutService).to have_received(:call).with(file_id: file_id)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).to have_received(:perform_in).with(*worker_params)
    end
  end

  context 'when yandex api failed' do
    let(:success_status) { false }

    it 'is success' do
      expect(call_service).to be_success
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
      expect(::Yandex::ObjectStorage::PutService).to have_received(:call).with(file_id: file_id)
      expect(::Telegram::Message::SendService).to have_received(:call).with(tg_message_params)
    end
  end

  context 'when chat_id is nil' do
    let(:chat_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::ObjectStorage::PutService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when message_id is nil' do
    let(:message_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::ObjectStorage::PutService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when file_id is nil' do
    let(:file_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::ObjectStorage::PutService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end
end
