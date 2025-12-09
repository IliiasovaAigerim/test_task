require 'rails_helper'

RSpec.describe "Api::V1::PostsController", type: :request do
  let(:headers) do
    { "Content-Type" => "application/json" }
  end
  let(:user) { create(:user) }
  let(:valid_params) do
    {
      title: "Test Title",
      body: "Test body content",
      user_login: user.login
    }.to_json
  end
  let(:request) { post "/api/v1/posts", params: valid_params, headers: headers }

  shared_examples 'response details' do
    it "returns status 201" do
      request

      expect(response).to have_http_status(:created)
    end

    it "returns created post in JSON" do
      request
      body = JSON.parse(response.body)

      expect(body["post"]["title"]).to eq("Test Title")
      expect(body["post"]["body"]).to eq("Test body content")
      expect(body["user"]["login"]).to eq(user.login)
    end

    it "stores request IP in the post" do
      headers.merge!("REMOTE_ADDR" => "123.45.67.89")
      request

      expect(Post.last.ip).to eq("123.45.67.89")
    end
  end

  context 'when login does not exist' do
    include_examples 'response details'

    it 'creates a new user' do
      expect {request}.to change(User, :count).by(1)
    end

    it "creates a post linked to that user" do
      expect {request}.to change(Post, :count).by(1)
    end
  end

  context 'when login already exists' do
    before do
      user
    end

    include_examples 'response details'

    it 'does not create a new user' do
      expect { request }.not_to change(User, :count)
    end

    it 'creates a new post on the same user' do
      request

      expect(Post.last.user_id).to eq(user.id)
    end
  end
end
