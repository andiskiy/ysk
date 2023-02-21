# frozen_string_literal: true

class ApplicationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
end
