class Rack::Attack
  redis = ENV['REDISTOGO_URL'] || 'localhost'
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisStore.new(redis)

  throttle('req/ip', :limit => 1000, :period => 10.minutes) do |req|
    req.ip if req.path.starts_with?('/api/v1')
  end
end

Rack::Attack.throttled_response = lambda do |env|
  now = Time.now
  match_data = env['rack.attack.match_data']

  headers = {
    'X-RateLimit-Limit' => match_data[:limit].to_s,
    'X-RateLimit-Remaining' => '0',
    'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  }

  [ 429, headers, [Api::V1::ErrorSerializer.new(429, 'Too  many requests').to_json]]
end
