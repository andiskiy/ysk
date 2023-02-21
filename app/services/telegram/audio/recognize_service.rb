# frozen_string_literal: true

module Telegram
  module Audio
    class RecognizeService < ApplicationService
      SUCCESS_CODE = 200

      attr_accessor :chat_id, :file_id, :message_id

      def process
        validate

        send_message_to_tg
      end

      private

      def validate
        %w[chat_id message_id file_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end

        errors.add(:audio_file, :not_found) if audio_file.response_code != SUCCESS_CODE
      end

      def send_message_to_tg
        Telegram.bot.send_message(chat_id: chat_id, text: generate_tg_message, reply_to_message_id: message_id)
      end

      def yandex_api
        @yandex_api ||= ::Api::Yandex::SpeechKit.call(file: audio_file.response_body)
      end

      def generate_tg_message
        return I18n.t('telegram.errors.invalid_audio_file') if failed?

        if yandex_api.success?
          yandex_api.response_body['result'].presence || I18n.t('telegram.errors.failed_recognize')
        else
          I18n.t('telegram.errors.failed_recognize')
        end
      end

      def audio_file
        @audio_file ||= ::Api::Telegram::DownloadFile.call(file_path: file_path)
      end

      def file_path
        tg_result = Telegram.bot.get_file(file_id: file_id)

        halt(:file, :invalid_request) unless tg_result['ok']

        tg_result['result']['file_path']
      end
    end
  end
end
