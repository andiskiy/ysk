# frozen_string_literal: true

module Telegram
  module Message
    class SendService < ApplicationService
      attr_accessor :text, :chat_id, :reply_to_message_id

      def process
        validate

        send_message
      end

      private

      def validate
        %w[text chat_id reply_to_message_id].each do |key|
          halt(key.to_sym, :blank) if send(key).blank?
        end
      end

      def send_message
        Telegram.bot.send_message(chat_id: chat_id, text: text, reply_to_message_id: reply_to_message_id)
      end
    end
  end
end
