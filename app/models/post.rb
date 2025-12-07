class Post < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, :title, :ip, presence: true
  validates :body, presence: true, length: { maximum: 140 }
end
