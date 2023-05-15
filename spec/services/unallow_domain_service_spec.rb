# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnallowDomainService, type: :service do
  subject { UnallowDomainService.new }

  let!(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let!(:first_bad_status) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let!(:second_bad_status) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let!(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: second_bad_status, file: attachment_fixture('attachment.jpg')) }
  let!(:already_banned_account) { Fabricate(:account, username: 'badguy', domain: 'evil.org', suspended: true, silenced: true) }
  let!(:domain_allow) { Fabricate(:domain_allow, domain: 'evil.org') }

  context 'with limited federation mode' do
    before do
      allow(subject).to receive(:whitelist_mode?).and_return(true)
    end

    describe '#call' do
      before do
        subject.call(domain_allow)
      end

      it 'removes the allowed domain' do
        expect(DomainAllow.allowed?('evil.org')).to be false
      end

      it 'removes remote accounts from that domain' do
        expect(Account.where(domain: 'evil.org').exists?).to be false
      end

      it 'removes the remote accounts\'s statuses and media attachments' do
        expect { first_bad_status.reload }.to raise_exception ActiveRecord::RecordNotFound
        expect { second_bad_status.reload }.to raise_exception ActiveRecord::RecordNotFound
        expect { bad_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end

  context 'without limited federation mode' do
    before do
      allow(subject).to receive(:whitelist_mode?).and_return(false)
    end

    describe '#call' do
      before do
        subject.call(domain_allow)
      end

      it 'removes the allowed domain' do
        expect(DomainAllow.allowed?('evil.org')).to be false
      end

      it 'does not remove accounts from that domain' do
        expect(Account.where(domain: 'evil.org').exists?).to be true
      end

      it 'removes the remote accounts\'s statuses and media attachments' do
        expect { first_bad_status.reload }.to_not raise_error
        expect { second_bad_status.reload }.to_not raise_error
        expect { bad_attachment.reload }.to_not raise_error
      end
    end
  end
end
