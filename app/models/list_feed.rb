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

    if media_only?
      # Get more IDs from Redis since we'll filter some out
      unhydrated_ids = from_redis_ids(limit * 3, max_id, since_id, min_id)

      # Filter to only statuses with media attachments and preserve order
      status_ids_with_media = Status.where(id: unhydrated_ids)
                                    .joins(:media_attachments)
                                    .group('statuses.id')
                                    .pluck(:id)

      # Return statuses in the correct order, limited
      filtered_ids = unhydrated_ids.select { |id| status_ids_with_media.include?(id) }.take(limit)
      Status.where(id: filtered_ids).index_by(&:id).values_at(*filtered_ids).compact
    else
      from_redis(limit, max_id, since_id, min_id)
    end
  end

  protected

  def from_redis_ids(limit, max_id, since_id, min_id)
    max_id = '+inf' if max_id.blank?
    if min_id.blank?
      since_id = '-inf' if since_id.blank?
      redis.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: [0, limit], with_scores: true).map { |id| id.first.to_i }
    else
      redis.zrangebyscore(key, "(#{min_id}", "(#{max_id}", limit: [0, limit], with_scores: true).map { |id| id.first.to_i }
    end
  end

  private

  attr_reader :options

  def media_only?
    options[:only_media]
  end
end
