# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::NoteSerializer do
  subject { JSON.parse(@serialization.to_json) }

  let!(:account) { Fabricate(:account) }
  let!(:other)   { Fabricate(:account) }
  let!(:parent)  { Fabricate(:status, account: account, visibility: :public) }
  let!(:first_reply) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:second_reply) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:third_reply) { Fabricate(:status, account: other, thread: parent, visibility: :public) }
  let!(:fourth_reply) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:fifth_reply) { Fabricate(:status, account: account, thread: parent, visibility: :direct) }

  before(:each) do
    @serialization = ActiveModelSerializers::SerializableResource.new(parent, serializer: described_class, adapter: ActivityPub::Adapter)
  end

  it 'has a Note type' do
    expect(subject['type']).to eql('Note')
  end

  it 'has a replies collection' do
    expect(subject['replies']['type']).to eql('Collection')
  end

  it 'has a replies collection with a first Page' do
    expect(subject['replies']['first']['type']).to eql('CollectionPage')
  end

  it 'includes public self-replies in its replies collection' do
    expect(subject['replies']['first']['items']).to include(first_reply.uri, second_reply.uri, fourth_reply.uri)
  end

  it 'does not include replies from others in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(third_reply.uri)
  end

  it 'does not include replies with direct visibility in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(fifth_reply.uri)
  end
end
