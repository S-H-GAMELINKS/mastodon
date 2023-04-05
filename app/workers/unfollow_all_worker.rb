# frozen_string_literal: true

class UnfollowAllWorker
  include Sidekiq::Worker
  
  def perform(source_account_id)
    UnfollowAllService.new.call(source_account_id)
  end
end
