# frozen_string_literal: true

module Yandex
  module AsyncSpeechKit
    class TranscribeService < ApplicationService
      DIVISOR = 6 # для вычисления времени распознавания. 1 минута распознается за 10 секунд
      MEASUREMENT_ERROR = 5 # seconds

      attr_accessor :chat_id, :file_id, :duration, :message_id

      def process
        validate

        handle_audio
      end

      private

      def validate
        %w[chat_id message_id duration file_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end
      end

      def handle_audio
        if yandex_api.success?
          call_worker
        else
          send_message
        end
      end

      def call_worker
        Yandex::AsyncSpeechKit::OperationWorker.perform_in(
          perform_worker_at,
          chat_id,
          message_id,
          yandex_api.response_body['id'],
        )
      end

      def send_message
        ::Telegram::Message::SendService.call(
          chat_id: chat_id,
          text: I18n.t('telegram.errors.failed_recognize'),
          reply_to_message_id: message_id,
        )
      end

      def perform_worker_at
        ((duration / DIVISOR) + MEASUREMENT_ERROR).seconds
      end

      def storage
        @storage ||= ::Yandex::ObjectStorage::PutService.call(file_id: file_id)
      end

      def yandex_api
        @yandex_api ||= ::Api::Yandex::AsyncSpeechKit::Transcribe.call(file_url: storage.result)
      end
    end
  end
end
