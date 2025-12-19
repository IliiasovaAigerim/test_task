require 'faker'
require 'json'

NUMBER_OF_POSTS = 200000
NUMBER_OF_USERS = 100
NUMBER_OF_UNIQUE_IPS = 50
THREADS = 15

BASE_URL = 'http://localhost:3000/api/v1'

WORD_COUNT_RANGE = 2..5
SENTENCE_COUNT_RANGE = 3..5

def curl_post(path, payload)
  json = payload.to_json.gsub('"', '\"')

  cmd = %(
    curl -s -o /dev/null -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -X POST #{BASE_URL}#{path} \
    -d "#{json}"
  )

  `#{cmd}`.to_i
end

def run_parallel(jobs)
  queue = Queue.new
  jobs.each { |job| queue << job }

  workers = THREADS.times.map do
    Thread.new do
      loop do
        begin
          job = queue.pop(true)
          job.call
        rescue ThreadError
          break
        end
      end
    end
  end

  workers.each(&:join)
end

Rails.logger.info "Cleaning database..."
Rating.delete_all
Post.delete_all
User.delete_all
Rails.logger.info "Database cleaned."

UNIQUE_IPS = Array.new(NUMBER_OF_UNIQUE_IPS) { Faker::Internet.unique.ip_v4_address }
USER_LOGINS = Array.new(NUMBER_OF_USERS) { Faker::Internet.unique.email }

Rails.logger.info "Creating #{NUMBER_OF_POSTS} posts..."

jobs = []

NUMBER_OF_POSTS.times do |i|
  jobs << proc do
    payload = {
      title: Faker::Lorem.sentence(word_count: rand(WORD_COUNT_RANGE)),
      body: Faker::Lorem.paragraph(sentence_count: rand(SENTENCE_COUNT_RANGE)),
      user_login: USER_LOGINS.sample,
      ip: UNIQUE_IPS.sample
    }

    curl_post('/posts', payload)
  end

  if jobs.size >= 1000
    run_parallel(jobs)
    jobs.clear
    Rails.logger.info "Processed #{i + 1} posts..."
  end
end

run_parallel(jobs) if jobs.any?

USER_ID_BY_LOGIN = User.pluck(:login, :id).to_h
post_ids = Post.ids

Rails.logger.info "Creating ratings (75%)..."

jobs = []
posts_to_rate = post_ids.sample((post_ids.size * 0.75).to_i)

posts_to_rate.each_with_index do |post_id, index|
  voters = USER_LOGINS.sample(rand(1..3).to_i)

  voters.each do |login|
    user_id = USER_ID_BY_LOGIN[login]
    next unless user_id

    jobs << proc do
      curl_post('/ratings', {
        post_id: post_id,
        user_id: user_id,
        value: rand(1..5)
      })
    end
  end

  if jobs.size >= 1000
    run_parallel(jobs)
    jobs.clear
    Rails.logger.info "Processed ratings for #{index + 1} posts..."
  end
end

run_parallel(jobs) if jobs.any?

Rails.logger.info "Seeding finished."
