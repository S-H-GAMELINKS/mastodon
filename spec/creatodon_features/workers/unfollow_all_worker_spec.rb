# frozen_string_literal: true

require 'rails_helper'

describe UnfollowAllWorker do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'jhon') }

  # ローカルのフォローしているユーザーのみの場合
  describe 'local' do
    let(:samuel) { Fabricate(:account, username: 'samuel') }
    let(:linda) { Fabricate(:account, username: 'linda') }

    before do
      sender.follow!(samuel)
      sender.follow!(linda)
      subject.perform(sender.id)
    end

    # フォロー関係は全て解消されている
    it 'destroys all following relation' do
      expect(sender.following?(samuel)).to be false
      expect(sender.following?(linda)).to be false
    end

    # フォロー数は0になっている
    it 'following count is 0' do
      expect(sender.following.count).to be 0
    end
  end

  # リモートのフォローしているユーザーのみの場合
  describe 'remote ActivityPub' do
    let(:samuel) { Fabricate(:account, username: 'samuel', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
    let(:linda) { Fabricate(:account, username: 'linda', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      sender.follow!(samuel)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      sender.follow!(linda)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      subject.perform(sender.id)
    end

    # フォロー関係は全て解消されている
    it 'destroys all following relation' do
      expect(sender.following?(samuel)).to be false
      expect(sender.following?(linda)).to be false
    end

    # フォロー数は0になっている
    it 'following count is 0' do
      expect(sender.following.count).to be 0
    end
  end

  # ローカルとリモートのユーザーをそれぞれフォローしている場合
  describe 'local and remote ActivityPub' do
    let(:samuel) { Fabricate(:account, username: 'samuel') }
    let(:linda) { Fabricate(:account, username: 'linda', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      sender.follow!(samuel)
      sender.follow!(linda)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      subject.perform(sender.id)
    end

    # フォロー関係は全て解消されている
    it 'destroys all following relation' do
      expect(sender.following?(samuel)).to be false
      expect(sender.following?(linda)).to be false
    end

    # フォロー数は0になっている
    it 'following count is 0' do
      expect(sender.following.count).to be 0
    end
  end
end
