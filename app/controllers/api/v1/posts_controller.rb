class Api::V1::PostsController < ApplicationController
  def create
    user = current_user || User.find_or_create_by(login: post_params[:user_login]) do |u|
      u.password = SecureRandom.hex(16)
    end

    ip_address = post_params[:ip].presence || request.remote_ip

    post = user.posts.build(
      title: post_params[:title],
      body: post_params[:body],
      ip: ip_address
    )
    if post.save
      render json: {
        post: post.as_json(only: [ :id, :title, :body, :ip, :user_id, :created_at ]),
        user: user.as_json(only: [ :id, :login ])
      }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def top
    n = params[:n].to_i
    return render json: { error: "N must be a positive integer." }, status: :bad_request unless n > 0
    posts = Post.with_average_rating.order(average_rating: :desc, id: :asc).limit(n)
    render json: posts.as_json(only: [ :id, :title, :body ])
  end

  private

  def post_params
    params.permit(:user_login, :title, :body, :ip)
  end
end
