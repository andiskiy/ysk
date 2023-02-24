# YSK

This is Yandex SpeechKit. App convert voice messages to text from telegram-bot.
## Used technologies

* Rails 7.0.4
* Ruby 3.1.3
* PostgreSQL
* Puma
* [Telegram-bot](https://github.com/telegram-bot-rb/telegram-bot)


## Environmental Variables
Before start the APP run command `cp .env.example .env` and specify the ENV variables. You should add the following ENV variables:
```
TELEGRAM_BOT_TOKEN=
TELEGRAM_BOT_USERNAME=
YANDEX_CLOUD_FOLDER_ID=
AWS_ACCESS_KEY_ID=                           => Yandex Object Storage
AWS_SECRET_ACCESS_KEY=                       => Yandex Object Storage
AWS_REGION=ru-central3                       => Yandex Object Storage
AWS_ENDPOINT=https://storage.yandexcloud.net => Yandex Object Storage
YANDEX_BUCKET_NAME=
YANDEX_CLOUD_API_KEY=
```
we use keys with the `AWS` prefix, because the gem [aws-sdk-s3](https://github.com/aws/aws-sdk-ruby) from AWS is suitable for Yandex

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
rails s
rake telegram:bot:poller
bundle exec sidekiq
```
