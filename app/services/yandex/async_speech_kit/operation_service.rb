# frozen_string_literal: true

module Yandex
  module AsyncSpeechKit
    class OperationService < ApplicationService
      NEXT_WORKER_RUN_TIME = 60 # seconds

      attr_accessor :chat_id, :message_id, :operation_id

      def process
        validate

        check_operation
      end

      private

      def validate
        %w[chat_id message_id operation_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end
      end

      def check_operation
        if yandex_api.success?
          response_body['done'] ? send_success_message : still_transcribing
        else
          send_failed_message
        end
      end

      def still_transcribing
        Yandex::AsyncSpeechKit::OperationWorker.perform_in(
          NEXT_WORKER_RUN_TIME.seconds,
          chat_id,
          message_id,
          operation_id,
        )
      end

      def send_success_message
        ::Telegram::Message::SendService.call(
          chat_id: chat_id,
          text: text,
          reply_to_message_id: message_id,
        )
      end

      def text
        response_body['response']['chunks'].map do |chunk|
          chunk['alternatives'].first['text']
        end.join(' ')
      end

      def send_failed_message
        ::Telegram::Message::SendService.call(
          chat_id: chat_id,
          text: I18n.t('telegram.errors.failed_recognize'),
          reply_to_message_id: message_id,
        )
      end

      def response_body
        @response_body ||= yandex_api.response_body
      end

      def yandex_api
        @yandex_api ||= ::Api::Yandex::AsyncSpeechKit::Operation.call(operation_id: operation_id)
      end
    end
  end
end
