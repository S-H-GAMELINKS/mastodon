# frozen_string_literal: true

if Rails.env.test? && ENV.fetch('E2E', nil)
  account = Account.where(username: 'S_H_').first_or_initialize(username: 'S_H_')
  account.save(validate: false)

  email = 'gamelinks007@gmail.com'
  password = 'MasterChief117'

  User.where(email: email).first_or_initialize(email: email, password: password, password_confirmation: password, confirmed_at: Time.now.utc, role: UserRole.find_by(name: 'Owner'), account: account, agreement: true, approved: true, locale: 'ja').save!

  user = User.where(email: email).first

  setting_data = { 'frequentlyUsedEmojis' => { 'grinning' => 1, 'pray' => 1, '+1' => 1, 'work_is_evil' => 9 },
                   'notifications' =>
  { 'alerts' =>
  { 'follow_request' => false,
    'favourite' => false,
    'update' => false,
    'mention' => false,
    'follow' => false,
    'status' => false,
    'admin.report' => false,
    'reblog' => false,
    'admin.sign_up' => false,
    'poll' => false },
    'quickFilter' => { 'active' => 'all', 'show' => true, 'advanced' => false },
    'dismissPermissionBanner' => false,
    'showUnread' => true,
    'shows' =>
  { 'follow_request' => true,
    'favourite' => true,
    'update' => true,
    'mention' => true,
    'follow' => true,
    'status' => true,
    'admin.report' => true,
    'reblog' => true,
    'admin.sign_up' => true,
    'poll' => true },
    'sounds' =>
  { 'follow_request' => false,
    'favourite' => true,
    'update' => true,
    'mention' => true,
    'follow' => true,
    'status' => true,
    'admin.report' => true,
    'reblog' => true,
    'admin.sign_up' => true,
    'poll' => true } },
                   'public' => { 'regex' => { 'body' => '' }, 'other' => { 'onlyMedia' => true, 'onlyRemote' => false, 'onlyLocal' => true, 'local' => true }, 'local' => true },
                   'direct' => { 'regex' => { 'body' => '' } },
                   'community' => { 'regex' => { 'body' => '' }, 'other' => { 'onlyMedia' => false } },
                   'skinTone' => 1,
                   'trends' => { 'show' => true },
                   'columns' =>
  [{ 'id' => 'COMPOSE', 'uuid' => 'd8d91590-80c5-49bd-b351-fd1cceea2021', 'params' => {} },
   { 'id' => 'HOME', 'uuid' => 'bf24b2aa-e476-437c-9292-771b54a9c87e', 'params' => {} },
   { 'id' => 'NOTIFICATIONS', 'uuid' => '3f337960-abb3-4563-ab4d-239c0d540d26', 'params' => {} }],
                   'introductionVersion' => 20_181_216_044_202,
                   'home' => { 'shows' => { 'reblog' => false, 'reply' => false }, 'regex' => { 'body' => '' }, 'other' => { 'onlyMedia' => true } } }

  Web::Setting.where(user: user).first_or_initialize(user: user, data: setting_data).save!

  FeaturedTag.create!(account: account, name: 'HALO')
end
