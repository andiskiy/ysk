# frozen_string_literal: true

class TelegramWebhookController < Telegram::Bot::UpdatesController
  def message(_message)
    respond_with :message, text: 'что то пошло не так'
  end

  def start!(_word = nil, *_other_words)
    response = from ? "Hello #{from['username']}!" : 'Hi there!'

    respond_with :message, text: response
  end
end
