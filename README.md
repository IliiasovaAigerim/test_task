**_Posts & Ratings REST API_**

A Ruby on Rails REST API application that allows users to create posts, 
rate them, and retrieve analytics such as top-rated posts and shared IP usage 
among different authors.

The project is built according to the provided technical 
task and focuses on correctness, concurrency safety, test coverage, and clean architecture.

**Features**

- Post Management: Create posts with automatic user creation/lookup and IP tracking.

- Concurrent Rating System: Rate posts with a unique user-per-post constraint. 
Uses an after_commit hook and database-level protections to ensure average 
ratings remain accurate under high concurrency.

- Top-N Analytics: Efficiently retrieve the highest-rated posts.

- IP Analytics: Identify IPs used by multiple authors.

**Tech Stack**

- Ruby: 3.4.7

- Framework: Rails 8.1.1

- Database: PostgreSQL

- Authentication: Devise

- Linting: RuboCop

- Testing: RSpec

**Installation**

1. Clone the repository:
    ```bash
    $ git clone git@github.com:IliiasovaAigerim/test_task.git
    $ cd test_task
    ```
2. Install dependencies:
   ```bash
    $ bundle install
    ```
3. Database Setup: Ensure PostgreSQL is running, then run:
   ```bash
    $ rails db:create
    $ rails db:migrate
    ```
4. Seeding Data (200K posts, 100 users, 50 unique IPs):
   ```bash
    $ rails db:seed
    ```
5. Start the rails server
    ```bash
    $ rails server
   ```

**API Endpoints**
1. Create a Post
    ````
        POST /api/v1/posts
        Params: title, body, login, ip
        Success: Returns post and user attributes.
    ````
2. Rate a Post
    ````
    POST /api/v1/ratings
    Params: post_id, user_id, value (1-5)
    Success: Returns the updated average rating of the post.
    Note: Handles concurrent requests to ensure data integrity.
    ````
3. Top N Posts
    ````
    GET /api/v1/posts/top/:n
    Returns: Array of post attributes sorted by average rating.
    ````
4. Shared IPs
    ````
    GET /api/v1/ips
    Returns: List of IPs used by multiple authors and the list of those authors.
    ````

**Testing & Linting**

1. Run RSpec tests:
    ````
   bundle exec rspec
   ````
2. Run RuboCop linting:
    ````
   bundle exec rubocop
   ````