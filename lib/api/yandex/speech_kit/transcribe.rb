# frozen_string_literal: true

module Api
  module Yandex
    module SpeechKit
      class Transcribe < ::Api::Yandex::Base
        BASE_URL = "https://stt#{BASE_DOMAIN}".freeze

        attr_accessor :file

        def process
          validate

          recognize
        end

        private

        def validate
          errors.add(:file, 'File is blank') if file.blank?
          failed? && halt
        end

        def recognize
          post("speech/v1/stt:recognize?folderId=#{ENV['YANDEX_CLOUD_FOLDER_ID']}&lang=ru-RU", file)

          errors.add(:speech, http_response) if response_code != SUCCESS_CODE
        end
      end
    end
  end
end
