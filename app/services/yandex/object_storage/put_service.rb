# frozen_string_literal: true

module Yandex
  module ObjectStorage
    class PutService < ApplicationService
      attr_accessor :file_id

      def process
        validate

        put_to_s3

        @result = "#{ENV['AWS_ENDPOINT']}/#{ENV['YANDEX_BUCKET_NAME']}/#{key}"
      end

      private

      def validate
        halt(:file_id, :blank) if file_id.blank?
        halt(:file, :not_found) if download_file_service.failed?
      end

      def put_to_s3
        Aws::S3::Client.new.put_object(
          bucket: ENV['YANDEX_BUCKET_NAME'],
          key: key,
          body: download_file_service.result[:file],
        )
      end

      def key
        @key ||= download_file_service.result[:file_path]
      end

      def download_file_service
        @download_file_service ||= ::Telegram::Audio::DownloadService.call(file_id: file_id)
      end
    end
  end
end
