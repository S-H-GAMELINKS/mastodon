# frozen_string_literal: true

class UserSettingsDecorator
  attr_reader :user, :settings

  def initialize(user)
    @user = user
  end

  def update(settings)
    @settings = settings
    process_update
  end

  private

  def process_update
    user.settings['notification_emails'] = merged_notification_emails if change?('notification_emails')
    user.settings['interactions']        = merged_interactions if change?('interactions')
    user.settings['default_privacy']     = default_privacy_preference if change?('setting_default_privacy')
    user.settings['default_sensitive']   = default_sensitive_preference if change?('setting_default_sensitive')
    user.settings['default_language']    = default_language_preference if change?('setting_default_language')
    user.settings['unfollow_modal']      = unfollow_modal_preference if change?('setting_unfollow_modal')
    user.settings['boost_modal']         = boost_modal_preference if change?('setting_boost_modal')
    user.settings['delete_modal']        = delete_modal_preference if change?('setting_delete_modal')
    user.settings['auto_play_gif']       = auto_play_gif_preference if change?('setting_auto_play_gif')
    user.settings['display_media']       = display_media_preference if change?('setting_display_media')
    user.settings['expand_spoilers']     = expand_spoilers_preference if change?('setting_expand_spoilers')
    user.settings['reduce_motion']       = reduce_motion_preference if change?('setting_reduce_motion')
    user.settings['disable_swiping']     = disable_swiping_preference if change?('setting_disable_swiping')
    user.settings['system_font_ui']      = system_font_ui_preference if change?('setting_system_font_ui')
    user.settings['noindex']             = noindex_preference if change?('setting_noindex')
    user.settings['theme']               = theme_preference if change?('setting_theme')
    user.settings['aggregate_reblogs']   = aggregate_reblogs_preference if change?('setting_aggregate_reblogs')
    user.settings['show_application']    = show_application_preference if change?('setting_show_application')
    user.settings['advanced_layout']     = advanced_layout_preference if change?('setting_advanced_layout')
    user.settings['use_blurhash']        = use_blurhash_preference if change?('setting_use_blurhash')
    user.settings['use_pending_items']   = use_pending_items_preference if change?('setting_use_pending_items')
    user.settings['trends']              = trends_preference if change?('setting_trends')
    user.settings['crop_images']         = crop_images_preference if change?('setting_crop_images')
    user.settings['always_send_emails']  = always_send_emails_preference if change?('setting_always_send_emails')
    user.settings['resized_custom_emoji'] = resized_custom_emoji if change?('setting_resized_custom_emoji')
    user.settings['resized_custom_emoji_stamp'] = resized_custom_emoji_stamp if change?('setting_resized_custom_emoji_stamp')
    user.settings['hide_local_timeline'] = hide_local_timeline if change?('setting_hide_local_timeline')
    user.settings['hide_federated_timeline'] = hide_federated_timeline if change?('setting_hide_federated_timeline')
    user.settings['show_otadon_tag_cloud'] = show_otadon_tag_cloud if change?('setting_show_otadon_tag_cloud')
  end

  def merged_notification_emails
    user.settings['notification_emails'].merge coerced_settings('notification_emails').to_h
  end

  def merged_interactions
    user.settings['interactions'].merge coerced_settings('interactions').to_h
  end

  def default_privacy_preference
    settings['setting_default_privacy']
  end

  def default_sensitive_preference
    boolean_cast_setting 'setting_default_sensitive'
  end

  def unfollow_modal_preference
    boolean_cast_setting 'setting_unfollow_modal'
  end

  def boost_modal_preference
    boolean_cast_setting 'setting_boost_modal'
  end

  def delete_modal_preference
    boolean_cast_setting 'setting_delete_modal'
  end

  def system_font_ui_preference
    boolean_cast_setting 'setting_system_font_ui'
  end

  def auto_play_gif_preference
    boolean_cast_setting 'setting_auto_play_gif'
  end

  def display_media_preference
    settings['setting_display_media']
  end

  def expand_spoilers_preference
    boolean_cast_setting 'setting_expand_spoilers'
  end

  def reduce_motion_preference
    boolean_cast_setting 'setting_reduce_motion'
  end

  def disable_swiping_preference
    boolean_cast_setting 'setting_disable_swiping'
  end

  def noindex_preference
    boolean_cast_setting 'setting_noindex'
  end

  def show_application_preference
    boolean_cast_setting 'setting_show_application'
  end

  def theme_preference
    settings['setting_theme']
  end

  def default_language_preference
    settings['setting_default_language']
  end

  def aggregate_reblogs_preference
    boolean_cast_setting 'setting_aggregate_reblogs'
  end

  def advanced_layout_preference
    boolean_cast_setting 'setting_advanced_layout'
  end

  def use_blurhash_preference
    boolean_cast_setting 'setting_use_blurhash'
  end

  def use_pending_items_preference
    boolean_cast_setting 'setting_use_pending_items'
  end

  def trends_preference
    boolean_cast_setting 'setting_trends'
  end

  def crop_images_preference
    boolean_cast_setting 'setting_crop_images'
  end

  def always_send_emails_preference
    boolean_cast_setting 'setting_always_send_emails'
  end

  def resized_custom_emoji
    settings['setting_resized_custom_emoji']
  end

  def resized_custom_emoji_stamp
    settings['setting_resized_custom_emoji_stamp']
  end

  def hide_local_timeline
    boolean_cast_setting 'setting_hide_local_timeline'
  end

  def hide_federated_timeline
    boolean_cast_setting 'setting_hide_federated_timeline'
  end

  def show_otadon_tag_cloud
    boolean_cast_setting 'setting_show_otadon_tag_cloud'
  end

  def boolean_cast_setting(key)
    ActiveModel::Type::Boolean.new.cast(settings[key])
  end

  def coerced_settings(key)
    coerce_values settings.fetch(key, {})
  end

  def coerce_values(params_hash)
    params_hash.transform_values { |x| ActiveModel::Type::Boolean.new.cast(x) }
  end

  def change?(key)
    !settings[key].nil?
  end
end
