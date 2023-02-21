# frozen_string_literal: true

class ErrorsSet
  def errors
    @errors ||= {}
  end

  def messages(flat: false)
    list = errors.dup

    flat ? flatten_messages(list) : list
  end

  def full_messages
    messages(flat: true)
  end

  def blank?
    errors.empty?
  end

  def any?
    errors.any?
  end

  def add(key, value, args = {})
    errors[key] ||= []

    case value
    when String then errors[key].push(value)
    else errors[key].push(key: key, value: value, args: args)
    end

    self
  end

  private

  def flatten_messages(messages)
    messages.map { |key, value| [key, value].reject(&:empty?).join(': ') }.flatten
  end
end
