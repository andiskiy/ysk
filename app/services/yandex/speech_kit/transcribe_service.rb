# frozen_string_literal: true

module Yandex
  module SpeechKit
    class TranscribeService < ApplicationService
      attr_accessor :file_id

      def process
        validate

        @result = text_message
      end

      private

      def validate
        halt(:file_id, :blank) if file_id.blank?
      end

      def text_message
        return I18n.t('telegram.errors.invalid_audio_file') if download_file_service.failed?

        if yandex_api.success?
          yandex_api.response_body['result'].presence || I18n.t('telegram.errors.failed_recognize')
        else
          I18n.t('telegram.errors.failed_recognize')
        end
      end

      def yandex_api
        @yandex_api ||= ::Api::Yandex::SpeechKit::Transcribe.call(file: download_file_service.result[:file])
      end

      def download_file_service
        @download_file_service ||= ::Telegram::Audio::DownloadService.call(file_id: file_id)
      end
    end
  end
end
