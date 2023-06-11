# frozen_string_literal: true

require 'nsfw'

class MediaNsfwCheckService < BaseService
  def call(media_ids)
    return false if media_ids.nil?

    # チェックする画像を取得
    medias = MediaAttachment.where(id: media_ids, type: :image)

    medias.map do |media|
      ::NSFW::Image.unsafe?(media.file.path)
    end.count(true).positive?
  end
end
