# frozen_string_literal: true

class ListFeed < Feed
  def initialize(list, options = {})
    @list = list
    @options = options
    super(:list, list.id)
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    limit    = limit.to_i
    max_id   = max_id.to_i if max_id.present?
    since_id = since_id.to_i if since_id.present?
    min_id   = min_id.to_i if min_id.present?

    statuses = from_redis(limit, max_id, since_id, min_id)

    statuses = statuses.joins(:media_attachments).group(:id) if media_only?

    statuses
  end

  private

  attr_reader :options

  def media_only?
    options[:only_media]
  end
end
