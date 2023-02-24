# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::SpeechKit::TranscribeService do
  subject(:call_service) { described_class.call(params) }

  let(:params) { { file_id: file_id } }
  let(:file_id) { Faker::Lorem.word }
  let(:file) { Faker::Lorem.word }
  let(:yandex_api_success) { true }
  let(:download_file_failed) { false }
  let(:yandex_api_result) { { result: result }.as_json }
  let(:result) { Faker::Lorem.word }

  before do
    allow(::Api::Yandex::SpeechKit::Transcribe).to(
      receive(:call)
        .with(file: file)
        .and_return(Struct.new(:success?, :response_body).new(yandex_api_success, yandex_api_result)),
    )

    allow(::Telegram::Audio::DownloadService).to(
      receive(:call)
        .with(file_id: file_id)
        .and_return(Struct.new(:failed?, :result).new(download_file_failed, file: file)),
    )
  end

  context 'when yandex api success & result filled' do
    it 'is success' do
      expect(call_service).to be_success
      expect(call_service.result).to eq(result)
    end
  end

  context 'when yandex api success & result blank' do
    let(:result) { '' }

    it 'is success' do
      expect(call_service).to be_success
      expect(call_service.result).to eq(I18n.t('telegram.errors.failed_recognize'))
    end
  end

  context 'when yandex api failed' do
    let(:yandex_api_success) { false }

    it 'is success' do
      expect(call_service).to be_success
      expect(call_service.result).to eq(I18n.t('telegram.errors.failed_recognize'))
    end
  end

  context 'when download file failed' do
    let(:download_file_failed) { true }

    it 'is success' do
      expect(call_service).to be_success
      expect(call_service.result).to eq(I18n.t('telegram.errors.invalid_audio_file'))
      expect(::Api::Yandex::SpeechKit::Transcribe).not_to have_received(:call)
    end
  end


  context 'when file_id is nil' do
    let(:file_id) { nil }

    it 'is failed' do
      expect(call_service).to be_failed
      expect(::Api::Yandex::SpeechKit::Transcribe).not_to have_received(:call)
      expect(::Telegram::Audio::DownloadService).not_to have_received(:call)
    end
  end
end
