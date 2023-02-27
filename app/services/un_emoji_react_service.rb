# frozen_string_literal: true

class UnEmojiReactService < BaseService
  include Redisable
  include Payloadable

  def call(account_id, status_id, emoji_reaction = nil)
    @account_id = account_id
    @account    = Account.find(account_id)
    @status     = Status.find(status_id)

    if emoji_reaction
      create_notification(emoji_reaction) if !@account.local? && @account.activitypub?
      notify_to_followers(emoji_reaction) if @account.local?
      write_stream(emoji_reaction)
    else
      bulk(@account, @status)
    end
    emoji_reaction
  end

  private

  def bulk(account, status)
    EmojiReaction.where(account: account).where(status: status).tap do |emoji_reaction|
      call(account, status, emoji_reaction)
    end
  end

  def create_notification(emoji_reaction)
    ActivityPub::DeliveryWorker.perform_async(build_json(emoji_reaction), @account_id, @account.inbox_url)
  end

  def notify_to_followers(emoji_reaction)
    ActivityPub::RawDistributionWorker.perform_async(build_json(emoji_reaction), @account_id)
  end

  def write_stream(emoji_reaction)
    emoji_group = @status.emoji_reactions_grouped_by_name
                                .find { |reaction_group| reaction_group['name'] == emoji_reaction.name && (!reaction_group.key?(:domain) || reaction_group['domain'] == emoji_reaction.custom_emoji&.domain) }
    if emoji_group
      emoji_group['status_id'] = @status.id.to_s
    else
      # name: emoji_reaction.name, count: 0, domain: emoji_reaction.domain
      emoji_group = { 'name' => emoji_reaction.name, 'count' => 0, 'account_ids' => [], 'status_id' => @status.id.to_s }
      emoji_group['domain'] = emoji_reaction.custom_emoji.domain if emoji_reaction.custom_emoji
    end
    FeedAnyJsonWorker.perform_async(render_emoji_reaction(emoji_group), @status.id, @account_id)
  end

  def build_json(emoji_reaction)
    Oj.dump(serialize_payload(emoji_reaction, ActivityPub::UndoEmojiReactionSerializer))
  end

  def render_emoji_reaction(emoji_group)
    # @rendered_emoji_reaction ||= InlineRenderer.render(emoji_group, nil, :emoji_reaction)
    Oj.dump(event: :emoji_reaction, payload: emoji_group.to_json)
  end
end
