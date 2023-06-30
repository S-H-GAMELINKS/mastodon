# frozen_string_literal: true

# 投稿自動削除用のService
class DeleteStatusService < BaseService
  def call(status_id)
    @status = Status.find(status_id)

    @status.discard_with_reblogs
    StatusPin.find_by(status: @status)&.destroy
    @status.account.statuses_count = @status.account.statuses_count - 1

    RemovalWorker.perform_async(@status.id, { 'redraft' => true })
  end
end
