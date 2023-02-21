# frozen_string_literal: true

module Telegram
  module Audio
    class RecognizeWorker < ApplicationWorker
      sidekiq_options retry: false

      def perform(chat_id, message_id, file_id); end
    end
  end
end
