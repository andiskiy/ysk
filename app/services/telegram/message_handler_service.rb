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
      halt(:voice, :blank) if voice.blank?
      errors.add(:chat_id, :not_found) if chat['id'].blank?
      errors.add(:message_id, :not_found) if params['message_id'].blank?
    end

    def call_worker
      # code
    end

    def voice
      @voice ||= params['voice'].presence || {}
    end

    def chat
      @chat ||= params['chat'].presence || {}
    end
  end
end
