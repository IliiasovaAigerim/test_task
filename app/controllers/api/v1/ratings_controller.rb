class Api::V1::RatingsController < ApplicationController
  def create
    post = Post.find(rating_params[:post_id])
    rating = post.ratings.build(
      post_id: rating_params[:post_id],
      user_id: rating_params[:user_id],
      value: rating_params[:value],
    )
    if rating.save
      render json: { average_rating: post.reload.average_rating }, status: :created
    else
      render json: { errors: rating.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    return render json: { error: 'Post not found' }, status: :not_found
  end

  private

  def rating_params
    params.permit(:post_id, :user_id, :value)
  end
end
