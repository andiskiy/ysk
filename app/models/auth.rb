# frozen_string_literal: true

class Auth < ApplicationRecord
  class << self
    def instance
      first || Auth.create(expires_at: 1.minute.ago)
    end

    def method_missing(method, *args)
      if Auth.instance.methods.include?(method)
        Auth.instance.send(method, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end

    def expired?
      return true if expires_at.blank?

      ::Time.at(expires_at - 300) < ::Time.current
    end
  end
end
