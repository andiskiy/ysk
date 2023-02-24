# frozen_string_literal: true

module Telegram
  module Audio
    class RecognizeWorker < ApplicationWorker
      sidekiq_options retry: false

      def perform(chat_id, file_id, duration, message_id)
        ::Telegram::Audio::RecognizeService.call(
          chat_id: chat_id,
          file_id: file_id,
          duration: duration,
          message_id: message_id,
        )
      end
    end
  end
end
