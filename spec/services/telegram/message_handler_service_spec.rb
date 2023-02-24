# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::MessageHandlerService do
  subject(:call_service) { described_class.call(params: params) }

  let(:params) do
    {
      'message_id' => message_id,
      'from' => {
        'id' => 261591206,
        'is_bot' => false,
        'first_name' => 'Magomed',
        'username' => 'andiskiy',
        'language_code' => 'ru',
        'is_premium' => true
      },
      'chat' => chat,
      'date' => 1676987124,
      'voice' => voice
    }
  end

  let(:message_id) { Faker::Number.number }

  let(:chat) do
    {
      'id' => 261591206,
      'first_name' => 'Magomed',
      'username' => 'andiskiy',
      'type' => 'private'
    }
  end

  let(:voice) do
    {
      'duration' => 1,
      'mime_type' => 'audio/ogg',
      'file_id' => 'AwACAgIAAxkBAAMqY_TK9DwscFgXN69vCp9pmG_Ir0sAAkEoAAKDQ6lLnBQSgS2mAW8uBA',
      'file_unique_id' => 'AgADQSgAAoNDqUs',
      'file_size' => 6575
    }
  end

  context 'when everything is ok' do
    before do
      allow(::Telegram::Audio::RecognizeWorker).to(
        receive(:perform_async).with(chat['id'], voice['file_id'], params['message_id']),
      )
    end

    it { expect(call_service).to be_success }
  end

  context 'when message_id is nil' do
    let(:message_id) { nil }

    it { expect(call_service).to be_failed }
  end

  context 'when message_id is missing' do
    before { params.delete('message_id') }

    it { expect(call_service).to be_failed }
  end

  context 'when chat is nil' do
    let(:chat) { nil }

    it { expect(call_service).to be_failed }
  end

  context 'when chat is blank' do
    let(:chat) { {} }

    it { expect(call_service).to be_failed }
  end

  context 'when chat is missing' do
    before { params.delete('chat') }

    it { expect(call_service).to be_failed }
  end

  context 'when voice is nil' do
    let(:voice) { nil }

    it { expect(call_service).to be_failed }
  end

  context 'when voice is blank' do
    let(:voice) { {} }

    it { expect(call_service).to be_failed }
  end

  context 'when voice is missing' do
    before { params.delete('voice') }

    it { expect(call_service).to be_failed }
  end

  context 'when file_id is nil' do
    before { voice['file_id'] = nil }

    it { expect(call_service).to be_failed }
  end

  context 'when file_id is blank' do
    before { voice['file_id'] = '' }

    it { expect(call_service).to be_failed }
  end

  context 'when file_id is missing' do
    before { voice.delete('file_id') }

    it { expect(call_service).to be_failed }
  end
end
