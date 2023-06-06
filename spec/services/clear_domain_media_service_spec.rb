# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClearDomainMediaService, type: :service do
  subject { described_class.new }

  let!(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let!(:first_bad_status) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let!(:second_bad_status) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let!(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: second_bad_status, file: attachment_fixture('attachment.jpg')) }

  describe 'for a silence with reject media' do
    before do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :silence, reject_media: true))
    end

    it 'leaves the domains status and attachments, but clears media' do
      expect { first_bad_status.reload }.to_not raise_error
      expect { second_bad_status.reload }.to_not raise_error
      expect { bad_attachment.reload }.to_not raise_error
      expect(bad_attachment.file.exists?).to be false
    end
  end
end
