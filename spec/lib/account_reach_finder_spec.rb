# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountReachFinder do
  let(:account) { Fabricate(:account) }

  let(:first_follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-1') }
  let(:second_follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-2') }
  let(:third_follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/a/inbox', shared_inbox_url: 'https://foo.bar/inbox') }

  let(:first_mentioned) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/b/inbox', shared_inbox_url: 'https://foo.bar/inbox') }
  let(:second_mentioned) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-3') }
  let(:third_mentioned) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-4') }

  let(:unrelated_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/unrelated-inbox') }

  before do
    first_follower.follow!(account)
    second_follower.follow!(account)
    third_follower.follow!(account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: first_follower)
      status.mentions << Mention.new(account: first_mentioned)
    end

    Fabricate(:status, account: account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: second_mentioned)
      status.mentions << Mention.new(account: third_mentioned)
    end

    Fabricate(:status).tap do |status|
      status.mentions << Mention.new(account: unrelated_account)
    end
  end

  describe '#inboxes' do
    it 'includes the preferred inbox URL of followers' do
      expect(described_class.new(account).inboxes).to include(*[first_follower, second_follower, third_follower].map(&:preferred_inbox_url))
    end

    it 'includes the preferred inbox URL of recently-mentioned accounts' do
      expect(described_class.new(account).inboxes).to include(*[first_mentioned, second_mentioned, third_mentioned].map(&:preferred_inbox_url))
    end

    it 'does not include the inbox of unrelated users' do
      expect(described_class.new(account).inboxes).to_not include(unrelated_account.preferred_inbox_url)
    end
  end
end
