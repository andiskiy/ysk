# frozen_string_literal: true

module Api
  module Yandex
    module AsyncSpeechKit
      class Operation < ::Api::Yandex::Base
        BASE_URL = "https://operation#{BASE_DOMAIN}".freeze

        attr_accessor :operation_id

        def process
          validate

          operation
        end

        private

        def validate
          errors.add(:operation_id, 'Operation ID is blank') if operation_id.blank?
          failed? && halt
        end

        def operation
          get("operations/#{operation_id}")

          errors.add(:speech, http_response) if response_code != SUCCESS_CODE
        end
      end
    end
  end
end
