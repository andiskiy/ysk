# frozen_string_literal: true

module Api
  module Yandex
    class RefreshIamToken < ::Api::Yandex::Base
      BASE_URL = 'https://iam.api.cloud.yandex.net/'

      def process
        update_auth
      end

      private

      def update_auth
        result = update_token
        return if failed?

        Auth.instance.update(token: result['iamToken'], expires_at: result['expiresAt'])
      end

      def update_token
        post('iam/v1/tokens', body.to_json)

        errors.add(:token, http_response) if response_code != SUCCESS_CODE

        response_body
      end

      def body
        { 'yandexPassportOauthToken' => ENV['YANDEX_OAUTH_TOKEN'] }
      end
    end
  end
end
