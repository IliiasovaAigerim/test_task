class Api::V1::PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = current_user || User.find_or_create_by(login: params[:user_login]) do |u|
      u.password = SecureRandom.hex(16)
    end

    post = user.posts.build(
      title: params[:title],
      body: params[:body],
      ip: request.remote_ip
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
end