require 'rails_helper'

RSpec.describe "Api::V1::PostsController", type: :request do
  describe '#create' do
    let(:headers) { { "Content-Type" => "application/json" } }
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

        expect(body["post"]["title"]).to eql("Test Title")
        expect(body["post"]["body"]).to eql("Test body content")
        expect(body["user"]["login"]).to eql(user.login)
      end

      it "stores request IP in the post" do
        headers.merge!("REMOTE_ADDR" => "123.45.67.89")
        request

        expect(Post.last.ip).to eql("123.45.67.89")
      end
    end

    context 'when login does not exist' do
      it_behaves_like 'response details'

      it 'creates a new user' do
        expect { request }.to change(User, :count).by(1)
      end

      it "creates a post linked to that user" do
        expect { request }.to change(Post, :count).by(1)
      end
    end

    context 'when login already exists' do
      before do
        user
      end

      it_behaves_like 'response details'

      it 'does not create a new user' do
        expect { request }.not_to change(User, :count)
      end

      it 'creates a new post on the same user' do
        request

        expect(Post.last.user_id).to be(user.id)
      end
    end
  end

  describe '#top' do
    let(:request) { get "/api/v1/posts/top/#{n}" }
    let(:post_first) { create(:post, title: 'first post with rate 2', average_rating: 2) }
    let(:post_second) { create(:post, title: 'second post with rate 5', average_rating: 5) }
    let(:post_third) { create(:post, title: 'third post with rate 1', average_rating: 1) }
    let(:post_fourth) { create(:post, title: 'fourth post with rate 5', average_rating: 5) }
    let(:json_response) { JSON.parse(response.body) }

    before do
      post_first
      post_second
      post_third
      post_fourth
      request
    end

    context 'when successful request' do
      let(:n) { 3 }


      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns n posts' do
        expect(json_response.count).to be(3)
      end

      it 'returns top n posts ordered by average_rating DESC' do
        expect(json_response.first['title']).to eql('second post with rate 5')
        expect(json_response.second['title']).to eql('fourth post with rate 5')
        expect(json_response.third['title']).to eql('first post with rate 2')
      end

      it 'returns only id, title and body' do
        expect(json_response.first.keys).to include('id', 'title', 'body')
      end

      it 'does not return average_rating, ip and user_id' do
        expect(json_response.first.keys).not_to include('average_rating', 'ip', 'user_id')
      end
    end

    context 'when n is zero' do
      let(:n) { 0 }

      it 'returns status 400 bad request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        expect(json_response["error"]).to eql('N must be a positive integer.')
      end
    end
  end
end
