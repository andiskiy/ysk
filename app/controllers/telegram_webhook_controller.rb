# frozen_string_literal: true

class TelegramWebhookController < Telegram::Bot::UpdatesController
  def message(message)
    service = Telegram::MessageHandlerService.call(params: message)

    respond_with :message, text: I18n.t('telegram.errors.invalid_message') if service.failed?
  end

  def start!(_word = nil, *_other_words)
    response = from ? build_text : 'Привет всем!'

    respond_with :message, text: response
  end

  private

  def build_text
    "Привет #{from['username']}! Это Yandex SpeechKit. Я умею преобразовывать голосовые сообщения в текст."
  end
end
