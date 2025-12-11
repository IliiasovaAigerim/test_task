class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  default_scope -> { order(created_at: :desc) }
  validates :user_id, :title, :ip, presence: true
  validates :body, presence: true, length: { maximum: 500 }

  def update_average_rating!
    avg_rating = ratings.average(:value)
    update_column(:average_rating, avg_rating.to_f.round(2))
  end
end
