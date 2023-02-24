# frozen_string_literal: true

module Telegram
  module Audio
    class DownloadService < ApplicationService
      SUCCESS_CODE = 200

      attr_accessor :file_id

      def process
        validate

        @result = {
          file: audio_file.response_body,
          file_path: file_path
        }
      end

      private

      def validate
        halt(:file_id, :blank) if file_id.blank?
        halt(:file, :not_found) if audio_file.response_code != SUCCESS_CODE
      end

      def audio_file
        @audio_file ||= ::Api::Telegram::DownloadFile.call(file_path: file_path)
      end

      def file_path
        return @file_path if @file_path.present?

        tg_result = ::Telegram.bot.get_file(file_id: file_id)

        halt(:file, :invalid_request) unless tg_result['ok']

        @file_path = tg_result['result']['file_path']
      end
    end
  end
end
