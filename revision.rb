# frozen_string_literal: true

# .env.productionを読み込む
env = File.read('.env.production')

# 最新のコミットのハッシュを取得
hash = `git show --format='%H' --no-patch`

# 最新のコミットのハッシュをMASTODON_VERSION_METADATAに設定
env = env.gsub!(/^MASTODON_VERSION_METADATA=.+$/, "MASTODON_VERSION_METADATA=#{hash}")

# .env.productionへ置き換えたものを書き込む
File.write('.env.production', env)
