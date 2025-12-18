class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already rated this post" }

  after_commit(on: [ :create, :update ]) { post.update_average_rating! }
end
