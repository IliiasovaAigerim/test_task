source "https://rubygems.org"

ruby "3.4.7"

gem "rails", "~> 8.1.1"
gem "pg", "~> 1.6"
gem "devise"
gem "active_model_serializers"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

# eval_gemfile 'Gemfile_local' if File.exist?('Gemfile_local')
