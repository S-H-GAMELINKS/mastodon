# frozen_string_literal: true

class UnfollowAllService < BaseService

  def call(source_account_id)
    @source_account = Account.find(source_account_id)

    unfollow_all
  end

  private

  # アカウントのフォローをすべて解除
  def unfollow_all
    targets = Account.where(id: ::Follow.where(account: @source_account).select(:target_account_id))

    targets.find_each do |target_account|
        UnfollowService.new.call(@source_account, target_account)
      rescue => e
      end
  end
end
