# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper

  included do
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def full_asset_url(source, options = {})
    (Rails.configuration.x.use_s3 || Rails.configuration.x.use_open_stack_object_storage) ? source : URI.join(root_url, ActionController::Base.helpers.asset_url(source, options)).to_s
  end
end
