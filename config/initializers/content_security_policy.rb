# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

def host_to_url(str)
  "http#{Rails.configuration.x.use_https ? 's' : ''}://#{str}" unless str.blank?
end

base_host = Rails.configuration.x.web_domain

assets_host   = Rails.configuration.action_controller.asset_host
assets_host ||= host_to_url(base_host)

media_host   = host_to_url(ENV['S3_ALIAS_HOST'])
media_host ||= host_to_url(ENV['S3_CLOUDFRONT_HOST'])
media_host ||= host_to_url(ENV['S3_HOSTNAME']) if ENV['S3_ENABLED'] == 'true'
media_host ||= assets_host

google_host = 'https://www.googletagmanager.com'
google_host2 = 'https://googleads.g.doubleclick.net'
google_host3 = 'https://www.googleadservices.com'
google_host4 = 'https://www.google.co.jp'
google_host5 = 'https://www.google.com'
google_tag_script_hash = "'sha256-CS1WvLDd3zJOdxpEk+N+VigcWMa6V345p2HS0WYiFWE='"

Rails.application.config.content_security_policy do |p|
  p.base_uri        :none
  p.default_src     :none
  p.frame_ancestors :none
  p.font_src        :self, assets_host
  p.img_src         :self, :https, :data, :blob, assets_host
  p.style_src       :self, assets_host
  p.media_src       :self, :https, :data, assets_host
  p.frame_src       :self, :https
  p.manifest_src    :self, assets_host
  p.form_action     :self

  if Rails.env.development?
    webpacker_urls = %w(ws http).map { |protocol| "#{protocol}#{Webpacker.dev_server.https? ? 's' : ''}://#{Webpacker.dev_server.host_with_port}" }

    p.connect_src :self, :data, :blob, assets_host, media_host, Rails.configuration.x.streaming_api_base_url, *webpacker_urls
    p.script_src  :self, :unsafe_inline, :unsafe_eval, assets_host, google_host, google_host2, google_host3
    p.child_src   :self, :blob, assets_host
    p.worker_src  :self, :blob, assets_host
  else
    p.connect_src :self, :data, :blob, assets_host, media_host, Rails.configuration.x.streaming_api_base_url
    p.script_src  :self, assets_host, "'wasm-unsafe-eval'", google_host, google_host2, google_host3, google_host4, google_host5, google_tag_script_hash
    p.child_src   :self, :blob, assets_host
    p.worker_src  :self, :blob, assets_host
  end
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

Rails.application.config.content_security_policy_nonce_directives = %w(style-src)

Rails.application.reloader.to_prepare do
  PgHero::HomeController.content_security_policy do |p|
    p.script_src :self, :unsafe_inline, assets_host
    p.style_src  :self, :unsafe_inline, assets_host
  end

  PgHero::HomeController.after_action do
    request.content_security_policy_nonce_generator = nil
  end

  if Rails.env.development?
    LetterOpenerWeb::LettersController.content_security_policy do |p|
      p.child_src       :self
      p.connect_src     :none
      p.frame_ancestors :self
      p.frame_src       :self
      p.script_src      :unsafe_inline
      p.style_src       :unsafe_inline
      p.worker_src      :none
    end

    LetterOpenerWeb::LettersController.after_action do |p|
      request.content_security_policy_nonce_directives = %w(script-src)
    end
  end
end
