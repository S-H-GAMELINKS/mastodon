# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trends::Statuses do
  subject! { described_class.new(threshold: 5, review_threshold: 10, score_halflife: 8.hours) }

  let!(:at_time) { DateTime.new(2021, 11, 14, 10, 15, 0) }

  describe 'Trends::Statuses::Query' do
    let!(:query) { subject.query }
    let!(:today) { at_time }

    let!(:first_status) { Fabricate(:status, text: 'Foo', language: 'en', trendable: true, created_at: today) }
    let!(:second_status) { Fabricate(:status, text: 'Bar', language: 'en', trendable: true, created_at: today) }

    before do
      15.times { reblog(first_status, today) }
      12.times { reblog(second_status, today) }

      subject.refresh(today)
    end

    describe '#filtered_for' do
      let(:account) { Fabricate(:account) }

      it 'returns a composable query scope' do
        expect(query.filtered_for(account)).to be_a Trends::Query
      end

      it 'filters out blocked accounts' do
        account.block!(first_status.account)
        expect(query.filtered_for(account).to_a).to eq [second_status]
      end

      it 'filters out muted accounts' do
        account.mute!(second_status.account)
        expect(query.filtered_for(account).to_a).to eq [first_status]
      end

      it 'filters out blocked-by accounts' do
        first_status.account.block!(account)
        expect(query.filtered_for(account).to_a).to eq [second_status]
      end
    end
  end

  describe '#add' do
    let(:status) { Fabricate(:status) }

    before do
      subject.add(status, 1, at_time)
    end

    it 'records use' do
      expect(subject.send(:recently_used_ids, at_time)).to eq [status.id]
    end
  end

  describe '#query' do
    it 'returns a composable query scope' do
      expect(subject.query).to be_a Trends::Query
    end

    it 'responds to filtered_for' do
      expect(subject.query).to respond_to(:filtered_for)
    end
  end

  describe '#refresh' do
    let!(:today) { at_time }
    let!(:yesterday) { today - 1.day }

    let!(:first_status) { Fabricate(:status, text: 'Foo', language: 'en', trendable: true, created_at: yesterday) }
    let!(:second_status) { Fabricate(:status, text: 'Bar', language: 'en', trendable: true, created_at: today) }
    let!(:third_status) { Fabricate(:status, text: 'Baz', language: 'en', trendable: true, created_at: today) }

    before do
      13.times { reblog(first_status, today) }
      13.times { reblog(second_status, today) }
      4.times { reblog(third_status, today) }
    end

    context do
      before do
        subject.refresh(today)
      end

      it 'calculates and re-calculates scores' do
        expect(subject.query.limit(10).to_a).to eq [second_status, first_status]
      end

      it 'omits statuses below threshold' do
        expect(subject.query.limit(10).to_a).to_not include(third_status)
      end
    end

    it 'decays scores' do
      subject.refresh(today)
      original_score = second_status.trend.score
      expect(original_score).to be_a Float
      subject.refresh(today + subject.options[:score_halflife])
      decayed_score = second_status.trend.reload.score
      expect(decayed_score).to be <= original_score / 2
    end
  end

  def reblog(status, at_time)
    reblog = Fabricate(:status, reblog: status, created_at: at_time)
    subject.add(status, reblog.account_id, at_time)
  end
end
