# frozen_string_literal: true

module Telegram
  module Audio
    class RecognizeService < ApplicationService
      DURATION_LIMIT = 30 # seconds

      attr_accessor :chat_id, :file_id, :duration, :message_id

      def process
        validate

        if duration < DURATION_LIMIT
          recognize_now
        else
          recognize_async
        end
      end

      private

      def validate
        %w[chat_id message_id duration file_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end
      end

      def recognize_now
        ::Telegram::Message::SendService.call(
          chat_id: chat_id,
          text: text,
          reply_to_message_id: message_id,
        )
      end

      def recognize_async
        ::Yandex::AsyncSpeechKit::TranscribeService.call(
          chat_id: chat_id,
          file_id: file_id,
          duration: duration,
          message_id: message_id,
        )
      end

      def text
        ::Yandex::SpeechKit::TranscribeService.call(file_id: file_id).result
      end
    end
  end
end
