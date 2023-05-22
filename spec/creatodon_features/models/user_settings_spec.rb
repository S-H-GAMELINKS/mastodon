# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSettings do
  subject { described_class.new(json) }

  let(:json) { {} }

  # カスタム絵文字拡大設定
  describe 'resized custom emoji' do
    # デフォルトはtrue
    it 'default resized custom emoji is true' do
      expect(subject[:resized_custom_emoji]).to be true
    end

    # 有効にできる
    it 'set enabled resized custom emoji' do
      subject[:resized_custom_emoji] = true
      expect(subject[:resized_custom_emoji]).to be true
    end

    # 無効にできる
    it 'set disabled resized custom emoji' do
      subject[:resized_custom_emoji] = false
      expect(subject[:resized_custom_emoji]).to be false
    end
  end

  # ポートフォリオ用のデフォルトハッシュタグを使うかどうかのフラグ設定
  describe 'portfolio default hashtag flag' do
    # デフォルトはfale
    it 'portfolio default hashtag flag is true' do
      expect(subject[:portfolio_default_hashtag_flag]).to be false
    end

    # 有効にできる
    it 'set enabled portfolio default hashtag flag' do
      subject[:portfolio_default_hashtag_flag] = true
      expect(subject[:portfolio_default_hashtag_flag]).to be true
    end

    # 無効にできる
    it 'set disabled portfolio default hashtag flag' do
      subject[:portfolio_default_hashtag_flag] = false
      expect(subject[:portfolio_default_hashtag_flag]).to be false
    end
  end

  # ポートフォリオ用のデフォルトハッシュタグ設定
  describe 'portfolio default hashtag' do
    # デフォルトは空文字
    it 'portfolio default hashtag is empty string' do
      expect(subject[:portfolio_default_hashtag]).to eq('')
    end

    # デフォルトのハッシュタグを設定できる
    it 'set portfolio default hashtag' do
      subject[:portfolio_default_hashtag] = '#HALO'
      expect(subject[:portfolio_default_hashtag]).to eq('#HALO')
    end

    # 空の文字列に変更できる
    it 'set empty string for portfolio default hashtag' do
      subject[:portfolio_default_hashtag] = '#HALO'
      expect(subject[:portfolio_default_hashtag]).to eq('#HALO')

      subject[:portfolio_default_hashtag] = ''
      expect(subject[:portfolio_default_hashtag]).to eq('')
    end
  end

  # 引っ越し時のフォロー解除設定
  describe 'unfollow all when migrate' do
    # デフォルトはtrue
    it 'unfollow all when migrate is true' do
      expect(subject[:unfollow_all_when_migrate]).to be true
    end

    # 有効にできる
    it 'set enabled unfollow all when migrate' do
      subject[:unfollow_all_when_migrate] = true
      expect(subject[:unfollow_all_when_migrate]).to be true
    end

    # 無効にできる
    it 'set disabled unfollow all when migrate' do
      subject[:unfollow_all_when_migrate] = false
      expect(subject[:unfollow_all_when_migrate]).to be false
    end
  end
end
