require 'faker'
require 'benchmark'
require 'json'

NUM_OF_POSTS = 1000
NUM_OF_USERS = 20
NUM_OF_UNIQUE_IPS = 10
THREADS = 15

BASE_URL = 'http://localhost:3000/api/v1'

WORD_COUNT_RANGE = 2..5
SENTENCE_COUNT_RANGE = 3..5

TOTAL_START = Time.now

def measure(title)
  puts "#{title}..."
  time = Benchmark.realtime { yield }
  puts "#{title} finished in #{time.round(2)} seconds"
end

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


puts "Cleaning database..."
Rating.delete_all
Post.delete_all
User.delete_all
puts "Database cleaned."


UNIQUE_IPS = Array.new(NUM_OF_UNIQUE_IPS) { Faker::Internet.unique.ip_v4_address }
USER_LOGINS = Array.new(NUM_OF_USERS) { Faker::Internet.unique.email }

measure("Creating #{NUM_OF_POSTS} posts (curl + #{THREADS} threads)") do
  jobs = []

  NUM_OF_POSTS.times do |i|
    jobs << proc do
      payload = {
        title: Faker::Lorem.sentence(word_count: rand(WORD_COUNT_RANGE)),
        body: Faker::Lorem.paragraph(sentence_count: rand(SENTENCE_COUNT_RANGE)),
        user_login: USER_LOGINS.sample,
        ip: UNIQUE_IPS.sample
      }

      curl_post('/posts', payload)
    end

    if jobs.size >= 100
      run_parallel(jobs)
      jobs.clear
      print "."
    end
  end

  run_parallel(jobs) if jobs.any?
end

USER_ID_BY_LOGIN = User.pluck(:login, :id).to_h
post_ids = Post.pluck(Post.primary_key)

measure("Creating ratings (75%)") do
  jobs = []
  posts_to_rate = post_ids.sample((post_ids.size * 0.75).to_i)

  posts_to_rate.each do |post_id|
    voters = USER_LOGINS.sample(rand(3..6).to_i)

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

    if jobs.size >= 100
      run_parallel(jobs)
      jobs.clear
      print "#"
    end
  end

  run_parallel(jobs) if jobs.any?
end

puts "Seeding finished in #{(Time.now - TOTAL_START).round(2)} seconds"
