# frozen_string_literal: true

module Telegram
  module Audio
    class RecognizeService < ApplicationService
      attr_accessor :chat_id, :file_id, :message_id

      def process
        validate

        download_audio
      end

      private

      def validate
        %w[chat_id message_id file_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end
      end

      def download_audio
        ::Api::Telegram::DownloadFile.call(file_path: file_path)
      end

      def file_path
        tg_result = Telegram.bot.get_file(file_id: file_id)

        halt(:file, :invalid_request) unless tg_result['ok']

        tg_result['result']['file_path']
      end
    end
  end
end
