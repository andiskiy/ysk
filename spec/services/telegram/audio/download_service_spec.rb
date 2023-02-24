# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Audio::DownloadService do
  subject(:call_service) { described_class.call(params) }

  let(:params) { { file_id: file_id } }
  let(:file_id) { Faker::Lorem.word }
  let(:file_path) { 'voice/file_2.oga' }
  let(:response_code) { 200 }

  let(:get_file_response) do
    {
      'ok' => true,
      'result' => {
        'file_id' => file_id,
        'file_path' => file_path,
        'file_unique_id' => Faker::Lorem.word
      }
    }
  end

  before do
    allow(::Api::Telegram::DownloadFile).to(
      receive(:call)
        .with(file_path: file_path)
        .and_return(Struct.new(:response_body, :response_code).new('response_body', response_code)),
    )

    allow(Telegram.bot).to receive(:get_file).with(file_id: file_id).and_return(get_file_response)
  end

  it 'is success' do
    expect(call_service).to be_success
    expect(call_service.result[:file]).to eq('response_body')
    expect(call_service.result[:file_path]).to eq(file_path)
  end

  context 'when get_file is failed' do
    let(:get_file_response) { { 'ok' => false } }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Api::Telegram::DownloadFile).not_to have_received(:call).with(file_path: file_path)
    end
  end

  context 'when audio file not found' do
    let(:response_code) { 401 }

    it { expect(call_service).to be_failed }
  end

  context 'when file_id is blank' do
    let(:file_id) { '' }

    it { expect(call_service).to be_failed }
  end
end
