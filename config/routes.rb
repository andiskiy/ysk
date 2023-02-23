# frozen_string_literal: true

Rails.application.routes.draw do
  resource :welcomes, only: :show
  root 'welcomes#show'

  telegram_webhook TelegramWebhookController
end
