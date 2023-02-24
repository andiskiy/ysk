# frozen_string_literal: true

module Api
  module Yandex
    class Base < ::Api::ApplicationApi
      BASE_DOMAIN = '.api.cloud.yandex.net/'
      SUCCESS_CODE = 200

      private

      def headers
        {
          Authorization: "Api-Key #{ENV['YANDEX_CLOUD_API_KEY']}"
        }
      end
    end
  end
end
