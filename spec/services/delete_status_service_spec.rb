# frozen_string_luteral: true

require 'rails_helper'

describe DeleteStatusService do
  describe '#call' do
    context 'with status' do
      let(:status) { Fabricate(:status) }

      it 'delete status' do
        expect { subject.call(status.id) }.to change { Status.count }.from(1).to(0)
      end
    end

    context 'with out status' do
      it 'warn log' do
        expect(Rails.logger).to receive(:warn)
        subject.call(0)
      end
    end
  end
end

