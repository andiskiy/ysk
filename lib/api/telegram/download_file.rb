# frozen_string_literal: true

module Api
  module Telegram
    class DownloadFile < ::Api::Telegram::Base
      attr_accessor :file_path

      def process
        get("/file/bot#{ENV['TELEGRAM_BOT_TOKEN']}/#{file_path}")
      end

      def response_body
        http_response.try(:body)
      end
    end
  end
end
