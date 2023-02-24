# frozen_string_literal: true

module Yandex
  module AsyncSpeechKit
    class OperationWorker < ApplicationWorker
      sidekiq_options retry: false

      def perform(chat_id, file_id, message_id, operation_id)
        ::Yandex::AsyncSpeechKit::OperationService.call(
          chat_id: chat_id,
          file_id: file_id,
          message_id: message_id,
          operation_id: operation_id,
        )
      end
    end
  end
end
