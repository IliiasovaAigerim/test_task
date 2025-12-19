class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :user_id, :title, :ip, presence: true
  validates :body, presence: true, length: { maximum: 500 }
end
