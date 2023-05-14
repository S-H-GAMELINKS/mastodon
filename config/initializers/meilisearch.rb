enabled = ENV['MS_ENABLED'] == 'true'

if enabled
  MeiliSearchCLient = MeiliSearch::Client.new(ENV.fetch(['MS_HOST'] + ENV.fetch(['MS_PORT'], ENV.fetch(['MS_KEY'])
end
