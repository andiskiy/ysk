# frozen_string_literal: true

module Telegram
  class MessageHandlerService < ApplicationService
    attr_accessor :params

    def process
      validate

      call_worker
    end

    private

    def validate
      halt(:file_id, :blank) if voice['file_id'].blank?
      halt(:chat_id, :not_found) if chat['id'].blank?
      halt(:message_id, :not_found) if params['message_id'].blank?
    end

    def call_worker
      ::Telegram::Audio::RecognizeWorker.perform_async(chat['id'], voice['file_id'], params['message_id'])
    end

    def voice
      @voice ||= params['voice'].presence || {}
    end

    def chat
      @chat ||= params['chat'].presence || {}
    end
  end
end
