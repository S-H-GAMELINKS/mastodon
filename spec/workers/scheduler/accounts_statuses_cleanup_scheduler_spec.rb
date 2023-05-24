# frozen_string_literal: true

require 'rails_helper'

describe Scheduler::AccountsStatusesCleanupScheduler do
  subject { described_class.new }

  let!(:first_account) { Fabricate(:account, domain: nil) }
  let!(:second_account)  { Fabricate(:account, domain: nil) }
  let!(:third_account)  { Fabricate(:account, domain: nil) }
  let!(:fourth_account) { Fabricate(:account, domain: nil) }
  let!(:fifth_account) { Fabricate(:account, domain: nil) }
  let!(:remote) { Fabricate(:account) }

  let!(:first_policy) { Fabricate(:account_statuses_cleanup_policy, account: first_account) }
  let!(:second_policy) { Fabricate(:account_statuses_cleanup_policy, account: third_account) }
  let!(:third_policy) { Fabricate(:account_statuses_cleanup_policy, account: fourth_account, enabled: false) }
  let!(:fourth_policy) { Fabricate(:account_statuses_cleanup_policy, account: fifth_account) }

  let(:queue_size)       { 0 }
  let(:queue_latency)    { 0 }
  let(:process_set_stub) do
    [
      {
        'concurrency' => 2,
        'queues' => %w(push default),
      },
    ]
  end

  before do
    queue_stub = double
    allow(queue_stub).to receive(:size).and_return(queue_size)
    allow(queue_stub).to receive(:latency).and_return(queue_latency)
    allow(Sidekiq::Queue).to receive(:new).and_return(queue_stub)
    allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set_stub)

    sidekiq_stats_stub = double
    allow(Sidekiq::Stats).to receive(:new).and_return(sidekiq_stats_stub)

    # Create a bunch of old statuses
    10.times do
      Fabricate(:status, account: first_account, created_at: 3.years.ago)
      Fabricate(:status, account: second_account, created_at: 3.years.ago)
      Fabricate(:status, account: third_account, created_at: 3.years.ago)
      Fabricate(:status, account: fourth_account, created_at: 3.years.ago)
      Fabricate(:status, account: fifth_account, created_at: 3.years.ago)
      Fabricate(:status, account: remote, created_at: 3.years.ago)
    end

    # Create a bunch of newer statuses
    5.times do
      Fabricate(:status, account: first_account, created_at: 3.minutes.ago)
      Fabricate(:status, account: second_account, created_at: 3.minutes.ago)
      Fabricate(:status, account: third_account, created_at: 3.minutes.ago)
      Fabricate(:status, account: fourth_account, created_at: 3.minutes.ago)
      Fabricate(:status, account: remote, created_at: 3.minutes.ago)
    end
  end

  describe '#under_load?' do
    context 'when nothing is queued' do
      it 'returns false' do
        expect(subject.under_load?).to be false
      end
    end

    context 'when numerous jobs are queued' do
      let(:queue_size)    { 5 }
      let(:queue_latency) { 120 }

      it 'returns true' do
        expect(subject.under_load?).to be true
      end
    end
  end

  describe '#compute_budget' do
    context 'with a single thread' do
      let(:process_set_stub) { [{ 'concurrency' => 1, 'queues' => %w(push default) }] }

      it 'returns a low value' do
        expect(subject.compute_budget).to be < 10
      end
    end

    context 'with a lot of threads' do
      let(:process_set_stub) do
        [
          { 'concurrency' => 2, 'queues' => %w(push default) },
          { 'concurrency' => 2, 'queues' => ['push'] },
          { 'concurrency' => 2, 'queues' => ['push'] },
          { 'concurrency' => 2, 'queues' => ['push'] },
        ]
      end

      it 'returns a larger value' do
        expect(subject.compute_budget).to be > 10
      end
    end
  end

  describe '#perform' do
    context 'when the budget is lower than the number of toots to delete' do
      it 'deletes as many statuses as the given budget' do
        expect { subject.perform }.to change(Status, :count).by(-subject.compute_budget)
      end

      it 'does not delete from accounts with no cleanup policy' do
        expect { subject.perform }.to_not change { second_account.statuses.count }
      end

      it 'does not delete from accounts with disabled cleanup policies' do
        expect { subject.perform }.to_not change { fourth_account.statuses.count }
      end

      it 'eventually deletes every deletable toot given enough runs' do
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 4

        expect { 10.times { subject.perform } }.to change(Status, :count).by(-30)
      end

      it 'correctly round-trips between users across several runs' do
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 3
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::PER_ACCOUNT_BUDGET', 2

        expect { 3.times { subject.perform } }
          .to change(Status, :count).by(-3 * 3)
          .and change { first_account.statuses.count }
          .and change { third_account.statuses.count }
          .and change { fifth_account.statuses.count }
      end

      context 'when given a big budget' do
        let(:process_set_stub) { [{ 'concurrency' => 400, 'queues' => %w(push default) }] }

        before do
          stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 400
        end

        it 'correctly handles looping in a single run' do
          expect(subject.compute_budget).to eq(400)
          expect { subject.perform }.to change(Status, :count).by(-30)
        end
      end

      context 'when there is no work to be done' do
        let(:process_set_stub) { [{ 'concurrency' => 400, 'queues' => %w(push default) }] }

        before do
          stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 400
          subject.perform
        end

        it 'does not get stuck' do
          expect(subject.compute_budget).to eq(400)
          expect { subject.perform }.to_not change(Status, :count)
        end
      end
    end
  end
end
