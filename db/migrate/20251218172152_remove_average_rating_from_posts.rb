class RemoveAverageRatingFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :average_rating, :float
  end
end
