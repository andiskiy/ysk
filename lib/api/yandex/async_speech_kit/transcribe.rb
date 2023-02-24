# frozen_string_literal: true

module Api
  module Yandex
    module AsyncSpeechKit
      class Transcribe < ::Api::Yandex::Base
        BASE_URL = "https://transcribe#{BASE_DOMAIN}".freeze

        attr_accessor :file_url

        def process
          validate

          transcribe
        end

        private

        def validate
          errors.add(:file_url, 'File url is blank') if file_url.blank?
          failed? && halt
        end

        def transcribe
          post('speech/stt/v2/longRunningRecognize', body)

          errors.add(:speech, http_response) if response_code != SUCCESS_CODE
        end

        def body
          {
            config: {
              specification: {
                languageCode: 'ru-RU'
              }
            },
            audio: {
              uri: file_url
            }
          }.to_json
        end
      end
    end
  end
end
