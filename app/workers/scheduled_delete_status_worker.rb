# frozen_string_literal: true

# 投稿自動削除用のジョブ
class ScheduledDeleteStatusWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed

  def perform(status_id)
    DeleteStatusService.new.call(status_id)
  end
end
