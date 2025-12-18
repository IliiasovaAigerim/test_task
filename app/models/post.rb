class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :user_id, :title, :ip, presence: true
  validates :body, presence: true, length: { maximum: 500 }

  scope :with_average_rating, -> {
    left_joins(:ratings)
      .select("posts.id, posts.title, posts.body, COALESCE(AVG(ratings.value), 0) AS average_rating")
      .group("posts.id")
  }
end
