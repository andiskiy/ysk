# frozen_string_literal: true

module Api
  class ApplicationApi

    class Error < StandardError; end

    attr_reader :rest_client_exception, :rest_client_response

    class << self
      def call(params = {})
        new(params).send(:call)
      end
    end

    def initialize(params = {})
      params.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    def http_response
      @rest_client_exception.presence || @rest_client_response
    end

    def response_body
      return if http_response.try(:body).blank?

      JSON.parse(http_response.body)
    end

    def response_code
      return if http_response.try(:code).blank?

      http_response.code
    end

    def success?
      errors.blank?
    end

    def failed?
      !success?
    end

    def errors
      @errors ||= ::ErrorsSet.new
    end

    private

    def call
      process

      self
    end

    def get(path)
      @rest_client_response = ::RestClient.get(full_path(path), headers)
    rescue ::RestClient::Exception => e
      @rest_client_exception = e
    end

    def post(path, body)
      @rest_client_response = ::RestClient.post(full_path(path), body, headers)
    rescue ::RestClient::Exception => e
      @rest_client_exception = e
    end

    def put(path, body)
      @rest_client_response = ::RestClient.put(full_path(path), body, headers)
    rescue ::RestClient::Exception => e
      @rest_client_exception = e
    end

    def patch(path, body)
      @rest_client_response = ::RestClient.patch(full_path(path), body, headers)
    rescue ::RestClient::Exception => e
      @rest_client_exception = e
    end

    def delete(path)
      @rest_client_response = ::RestClient.delete(full_path(path), headers)
    rescue ::RestClient::Exception => e
      @rest_client_exception = e
    end

    def headers
      {}
    end

    def full_path(path)
      path[0] = '' if path[0] == '/'

      self.class::BASE_URL + path
    end

    def halt
      raise Error
    end
  end
end
