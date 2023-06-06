# frozen_string_literal: true

return unless Rails.env.test?

Rails.application.load_tasks unless defined?(Rake::Task)

CypressRails.hooks.after_transaction_start do
  # Sidekiqで処理される投稿のジョブに必要
  Sidekiq::Testing.inline!
end
