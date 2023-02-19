# frozen_string_literal: true

if ENV['TELEGRAM_BOT_TOKEN'].present?
  Telegram.bots_config = {
    default: {
      token: ENV['TELEGRAM_BOT_TOKEN'],
      username: ENV['TELEGRAM_BOT_USERNAME']
    }
  }
end
