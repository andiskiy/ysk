# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Message::SendService do
  subject(:call_service) { described_class.call(params) }

  let(:params) do
    {
      text: text,
      chat_id: chat_id,
      reply_to_message_id: reply_to_message_id
    }
  end
  let(:chat_id) { Faker::Number.number }
  let(:text) { Faker::Lorem.word }
  let(:reply_to_message_id) { Faker::Number.number }

  before do
    allow(Telegram.bot).to receive(:send_message).with(params)
  end

  it 'is success' do
    expect(call_service).to be_success
    expect(Telegram.bot).to have_received(:send_message).with(params)
  end

  context 'when chat_id is nil' do
    let(:chat_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(Telegram.bot).not_to have_received(:send_message).with(params)
    end
  end

  context 'when text is blank' do
    let(:text) { '' }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(Telegram.bot).not_to have_received(:send_message).with(params)
    end
  end

  context 'when reply_to_message_id is nil' do
    let(:reply_to_message_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(Telegram.bot).not_to have_received(:send_message).with(params)
    end
  end
end
