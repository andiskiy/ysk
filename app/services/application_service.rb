# frozen_string_literal: true

class ApplicationService
  attr_accessor :result

  class Error < StandardError; end

  class << self
    def call(params = {})
      new(params).call
    end
  end

  def initialize(params = {})
    params.each do |attr, value|
      display_attr_warning(attr) && next unless respond_to?("#{attr}=")

      public_send("#{attr}=", value)
    end
  end

  def call
    return self if errors.present?

    begin
      process
    rescue Error
      nil
    end

    self
  end

  def process; end

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

  def halt(key = nil, message = nil, args = {})
    errors.add(key, message, args) if key

    raise Error
  end

  def display_attr_warning(attr)
    Rails.logger.warn("#{self.class.name}: attribute :#{attr} isn't added to the attributes list")
  end
end
