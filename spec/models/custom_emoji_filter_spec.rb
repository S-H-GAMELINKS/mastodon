# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomEmojiFilter do
  describe '#results' do
    subject { described_class.new(params).results }

    let!(:first_custom_emoji) { Fabricate(:custom_emoji, domain: 'a') }
    let!(:second_custom_emoji) { Fabricate(:custom_emoji, domain: 'b') }
    let!(:third_custom_emoji) { Fabricate(:custom_emoji, domain: nil, shortcode: 'hoge') }

    context 'when params have values' do
      context 'when local' do
        let(:params) { { local: true } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_a(ActiveRecord::Relation)
          expect(subject).to contain_exactly(third_custom_emoji)
        end
      end

      context 'when remote' do
        let(:params) { { remote: true } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_a(ActiveRecord::Relation)
          expect(subject).to contain_exactly(first_custom_emoji, second_custom_emoji)
        end
      end

      context 'with by_domain' do
        let(:params) { { by_domain: 'a' } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_a(ActiveRecord::Relation)
          expect(subject).to contain_exactly(first_custom_emoji)
        end
      end

      context 'when shortcode' do
        let(:params) { { shortcode: 'hoge' } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_a(ActiveRecord::Relation)
          expect(subject).to contain_exactly(third_custom_emoji)
        end
      end

      context 'when some other case' do
        let(:params) { { else: 'else' } }

        it 'raises Mastodon::InvalidParameterError' do
          expect do
            subject
          end.to raise_error(Mastodon::InvalidParameterError, /Unknown filter: else/)
        end
      end
    end

    context 'when params without value' do
      let(:params) { { hoge: nil } }

      it 'returns ActiveRecord::Relation' do
        expect(subject).to be_a(ActiveRecord::Relation)
        expect(subject).to contain_exactly(first_custom_emoji, second_custom_emoji, third_custom_emoji)
      end
    end
  end
end
