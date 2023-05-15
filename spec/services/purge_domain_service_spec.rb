# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeDomainService, type: :service do
  subject { PurgeDomainService.new }

  let!(:old_account) { Fabricate(:account, domain: 'obsolete.org') }
  let!(:first_old_status) { Fabricate(:status, account: old_account) }
  let!(:second_old_status) { Fabricate(:status, account: old_account) }
  let!(:old_attachment) { Fabricate(:media_attachment, account: old_account, status: second_old_status, file: attachment_fixture('attachment.jpg')) }

  describe 'for a suspension' do
    before do
      subject.call('obsolete.org')
    end

    it 'removes the remote accounts\'s statuses and media attachments' do
      expect { old_account.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { first_old_status.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { second_old_status.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
    end

    it 'refreshes instances view' do
      expect(Instance.where(domain: 'obsolete.org').exists?).to be false
    end
  end
end
