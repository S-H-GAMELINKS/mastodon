# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostStatusUpdatedWithVisibilityService, type: :service do
  subject { described_class.new }

  # 公開範囲「にゃーん」の場合
  describe 'create a new status with nyan visibility' do
    let(:jhon) { Fabricate(:account, username: 'jhon') }

    # すべて「にゃーん」に置き換えられる
    it 'create a new status with nyan visibility that replaced "にゃーん"' do
      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'nyan', spoiler_text: '')
      expect(result[0]).to be 'にゃーん'
      expect(result[1]).to be 'public'
      expect(result[2]).to be ''
    end

    # CWがある場合は警告も「にゃーん」に置き換わる
    it 'create a new contnt warning status with nyan visibility that replaced "にゃーん"' do
      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'nyan', spoiler_text: 'CW')
      expect(result[0]).to be 'にゃーん'
      expect(result[1]).to be 'public'
      expect(result[2]).to be 'にゃーん'
    end
  end

  # 公開範囲「ポートフォリオ」の場合
  describe 'create a new status with visibility portfolio' do
    let(:jhon) { Fabricate.build(:account, username: 'jhon') }

    # ポートフォリオとして投稿データを変更できる
    it 'create a new status with portfolio visibility' do
      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: '')
      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be ''
    end

    # CWがある場合でもポートフォリオとして投稿データを変更できる
    it 'create a new contnt warning status with portfolio visibility' do
      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: 'CW')
      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be 'CW'
    end

    # デフォルトのハッシュタグを設定している場合、そのハッシュタグも付与される
    it 'create a new status with portfolio visibility and set default hashtags' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = true
      jhon.user.settings['portfolio_default_hashtag'] = '#HALO'

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: '')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n#HALO\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be ''
    end

    # CWがある場合かつデフォルトのハッシュタグを設定している場合、そのハッシュタグも付与される
    it 'create a new contnt warning status with portfolio visibility and set default hashtags' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = true
      jhon.user.settings['portfolio_default_hashtag'] = '#HALO'

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: 'CW')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n#HALO\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be 'CW'
    end

    # デフォルトのハッシュタグを設定しているがハッシュタグを利用するフラグがOFFの場合、そのハッシュタグは付与されない
    it 'create a new status with portfolio visibility and not set default hashtags(flag is false)' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = false
      jhon.user.settings['portfolio_default_hashtag'] = '#HALO'

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: '')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be ''
    end

    # CWがある場合かつデフォルトのハッシュタグを設定しているがハッシュタグを利用するフラグがOFFの場合、そのハッシュタグは付与されない
    it 'create a new contnt warning status with portfolio visibility and not set default hashtags(flag is false)' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = false
      jhon.user.settings['portfolio_default_hashtag'] = '#HALO'

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: 'CW')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be 'CW'
    end

    # デフォルトのハッシュタグを設定しておらず、デフォルトのハッシュタグを利用するフラグがONの場合、何も付与されない
    it 'create a new status with portfolio visibility and not set default hashtags(default hashtag is empty)' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = true
      jhon.user.settings['portfolio_default_hashtag'] = ''

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: '')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be ''
    end

    # CWがある場合かつデフォルトのハッシュタグを設定しておらず、デフォルトのハッシュタグを利用するフラグがONの場合、何も付与されない
    it 'create a new contnt warning status with portfolio visibility and not set default hashtags(default hashtag is empty)' do
      jhon.user.settings['portfolio_default_hashtag_flag'] = true
      jhon.user.settings['portfolio_default_hashtag'] = ''

      result = subject.call(jhon.user, text: 'HALO is Awesome', visibility: 'portfolio', spoiler_text: 'CW')

      expect(result[0]).to eq("HALO is Awesome\n#CreatodonFolio\n\n")
      expect(result[1]).to be 'public'
      expect(result[2]).to be 'CW'
    end
  end
end
