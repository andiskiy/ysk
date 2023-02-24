# frozen_string_literal: true

module Yandex
  module ObjectStorage
    class DeleteService < ApplicationService
      attr_accessor :file_id

      def process
        validate

        delete_from_bucket
      end

      private

      def validate
        halt(:file_id, :blank) if file_id.blank?
      end

      def delete_from_bucket
        Aws::S3::Client.new.delete_object(
          bucket: ENV['YANDEX_BUCKET_NAME'],
          key: key,
        )
      end

      def key
        tg_result = ::Telegram.bot.get_file(file_id: file_id)

        halt(:file, :invalid_request) unless tg_result['ok']

        tg_result['result']['file_path']
      end
    end
  end
end
