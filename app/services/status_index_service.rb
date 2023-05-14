# frozen_string_literal: true

class StatusIndexService < BaseService
  def initialize
    @index = MeiliSearchCLient.index('local_timeline')
  end

  def call(status)
    @status = status
    documents = [
        status.to_h
    ]
    @index.add_documents(documents)
  end
end
