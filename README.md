# YSK

This is Yandex SpeechKit. App convert voice messages to text from telegram-bot.
## Used technologies

* Rails 7.0.4
* Ruby 3.1.3
* PostgreSQL
* Puma
* [Telegram-bot](https://github.com/telegram-bot-rb/telegram-bot)

## Getting Started

Install [RVM](https://rvm.io/) with Ruby 3.1.3.

Install gems:
```
gem install bundler
bundle install
```

##### Install DB

```
rake db:create
rake db:migrate
```

Rails start:

```
cp .env.example .env
rails s
rake telegram:bot:poller
bundle exec sidekiq
```
