# frozen_string_literal: true

module Api
  module Yandex
    class SpeechKit < ::Api::Yandex::Base
      attr_accessor :file

      def process
        validate
        return if failed?

        recognize
      end

      private

      def validate
        errors.add(:file, 'File is blank') if file.blank?
        refresh_token if Auth.expired?
      end

      def recognize
        post("speech/v1/stt:recognize?folderId=#{ENV['YANDEX_CLOUD_FOLDER_ID']}&lang=ru-RU", file)

        errors.add(:speech, http_response) if response_code != SUCCESS_CODE
      end

      def headers
        {
          Authorization: "Bearer #{Auth.token}"
        }
      end

      def refresh_token
        ::Api::Yandex::RefreshIamToken.call
      end
    end
  end
end
