# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::AsyncSpeechKit::OperationService do
  subject(:call_service) { described_class.call(params) }

  let(:params) do
    {
      chat_id: chat_id,
      message_id: message_id,
      operation_id: operation_id
    }
  end
  let(:chat_id) { Faker::Number.number }
  let(:message_id) { Faker::Number.number }
  let(:operation_id) { Faker::Number.number }

  let(:done) { true }
  let(:success_status) { true }
  let(:response_body) { success_done_result }
  let(:worker_params) { [described_class::NEXT_WORKER_RUN_TIME.seconds, chat_id, message_id, operation_id] }

  let(:success_done_result) do
    {
      done: done,
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
                text: text,
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

  let(:text) do
    'при написании хоббита толкин обращался к мотивам '\
      'скандинавской мифологии древней английской поэмы беовульф'
  end

  let(:params_failed_message) do
    {
      chat_id: chat_id,
      text: I18n.t('telegram.errors.failed_recognize'),
      reply_to_message_id: message_id
    }
  end

  let(:params_success_message) do
    {
      chat_id: chat_id,
      text: text,
      reply_to_message_id: message_id
    }
  end

  before do
    allow(::Api::Yandex::AsyncSpeechKit::Operation).to(
      receive(:call)
        .with(operation_id: operation_id)
        .and_return(Struct.new(:success?, :response_body).new(success_status, response_body)),
    )

    allow(::Telegram::Message::SendService).to receive(:call).with(params_success_message)

    allow(::Telegram::Message::SendService).to receive(:call).with(params_failed_message)

    allow(::Yandex::AsyncSpeechKit::OperationWorker).to(
      receive(:perform_in)
        .with(*worker_params),
    )
  end

  context 'when yandex api success and done' do
    it 'is success' do
      expect(call_service).to be_success
      expect(::Telegram::Message::SendService).to have_received(:call).with(params_success_message)
      expect(::Telegram::Message::SendService).not_to have_received(:call).with(params_failed_message)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when yandex api failed' do
    let(:success_status) { false }

    it 'is success' do
      expect(call_service).to be_success
      expect(::Telegram::Message::SendService).not_to have_received(:call).with(params_success_message)
      expect(::Telegram::Message::SendService).to have_received(:call).with(params_failed_message)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when it\'s not done yet' do
    let(:done) { false }

    it 'is success' do
      expect(call_service).to be_success
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).to have_received(:perform_in).with(*worker_params)
    end
  end

  context 'when chat_id is nil' do
    let(:chat_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when message_id is nil' do
    let(:message_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end

  context 'when operation_id is nil' do
    let(:operation_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Telegram::Message::SendService).not_to have_received(:call)
      expect(::Yandex::AsyncSpeechKit::OperationWorker).not_to have_received(:perform_in)
    end
  end
end
