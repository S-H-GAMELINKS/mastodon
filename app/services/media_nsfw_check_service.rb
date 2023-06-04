# frozen_string_literal: true

class MediaNsfwCheckService < BaseService
  def call(media_ids)
    # PyCallで opennsfw2をインポート
    n2 = PyCall.import_module('opennsfw2')

    # チェックする画像を取得
    medias = MediaAttachment.find(media_ids)

    medias.map do |media|
      n2.predict_image(media.file.path) > 0.9
    end.count(true).positive?
  end
end
