# frozen_string_literal: true

class MediaNsfwCheckService < BaseService
  def call(media_ids)
    # PyCallで opennsfw2をインポート
    n2 = PyCall.import_module('opennsfw2')

    # チェックする画像を取得
    medias = MediaAttachment.find(media_ids)

    images_path = medias.map { |media| media.file.path }

    n2.predict_images(images_path).max > 0.9
  end
end
