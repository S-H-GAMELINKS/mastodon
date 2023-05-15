# frozen_string_literal: true

require 'rails_helper'

describe TagFeed, type: :service do
  describe '#get' do
    let(:account) { Fabricate(:account) }
    let(:first_tag) { Fabricate(:tag) }
    let(:second_tag) { Fabricate(:tag) }
    let!(:first_status) { Fabricate(:status, tags: [first_tag]) }
    let!(:second_status) { Fabricate(:status, tags: [second_tag]) }
    let!(:both) { Fabricate(:status, tags: [first_tag, second_tag]) }

    it 'can add tags in "any" mode' do
      results = described_class.new(first_tag, nil, any: [second_tag.name]).get(20)
      expect(results).to include first_status
      expect(results).to include second_status
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = described_class.new(first_tag, nil, all: [second_tag.name]).get(20)
      expect(results).to_not include first_status
      expect(results).to_not include second_status
      expect(results).to     include both
    end

    it 'can remove tags in "none" mode' do
      results = described_class.new(first_tag, nil, none: [second_tag.name]).get(20)
      expect(results).to     include first_status
      expect(results).to_not include second_status
      expect(results).to_not include both
    end

    it 'ignores an invalid mode' do
      results = described_class.new(first_tag, nil, wark: [second_tag.name]).get(20)
      expect(results).to     include first_status
      expect(results).to_not include second_status
      expect(results).to     include both
    end

    it 'handles being passed non existent tag names' do
      results = described_class.new(first_tag, nil, any: ['wark']).get(20)
      expect(results).to     include first_status
      expect(results).to_not include second_status
      expect(results).to     include both
    end

    it 'can restrict to an account' do
      BlockService.new.call(account, first_status.account)
      results = described_class.new(first_tag, account, none: [second_tag.name]).get(20)
      expect(results).to_not include first_status
    end

    it 'can restrict to local' do
      first_status.account.update(domain: 'example.com')
      first_status.update(local: false, uri: 'example.com/toot')
      results = described_class.new(first_tag, nil, any: [second_tag.name], local: true).get(20)
      expect(results).to_not include first_status
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [first_tag], in_reply_to_id: original.id)

      results = described_class.new(first_tag, nil).get(20)
      expect(results).to include(status)
    end
  end
end
