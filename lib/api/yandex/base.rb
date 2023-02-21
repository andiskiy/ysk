# frozen_string_literal: true

module Api
  module Yandex
    class Base < ::Api::ApplicationApi
      BASE_URL = 'https://stt.api.cloud.yandex.net/'
      SUCCESS_CODE = 200
    end
  end
end
