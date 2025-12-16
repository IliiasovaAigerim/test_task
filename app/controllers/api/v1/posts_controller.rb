class Api::V1::PostsController < ApplicationController
  def create
    user = current_user || User.find_or_create_by(login: params[:user_login]) do |u|
      u.password = SecureRandom.hex(16)
    end

    ip_address = params[:ip].presence || request.remote_ip

    post = user.posts.build(
      title: params[:title],
      body: params[:body],
      ip: ip_address
    )
    if post.save
      render json: {
        post: post.as_json(only: [:id, :title, :body, :ip, :user_id, :created_at]),
        user: user.as_json(only: [:id, :login])
      }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def top
    n = params[:n].to_i
    return render json: { error: "N must be a positive integer." }, status: :bad_request unless n > 0
    posts = Post.order(average_rating: :desc).limit(n)
    render json:posts, each_serializer: TopPostSerializer
  end
end