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

    shared_examples "response details" do
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
      it_behaves_like "response details"
      it_behaves_like "a created request status"

      it('creates a new user') { expect { request }.to change(User, :count).by(1) }

      it("creates a post linked to that user") { expect { request }.to change(Post, :count).by(1) }
    end

    context 'when login already exists' do
      before { user }

      it_behaves_like 'response details'
      it_behaves_like "a created request status"

      it('does not create a new user') { expect { request }.not_to change(User, :count) }

      it 'creates a new post on the same user' do
        request

        expect(Post.last.user_id).to be(user.id)
      end
    end
  end

  describe '#top' do
    let(:request) { get "/api/v1/posts/top/#{n}" }
    let(:post_first) { create(:post, title: 'first post with rate 2') }
    let(:post_second) { create(:post, title: 'second post with rate 5') }
    let(:post_third) { create(:post, title: 'third post with rate 1') }
    let(:post_fourth) { create(:post, title: 'fourth post with rate 5') }
    let(:json_response) { JSON.parse(response.body) }

    before do
      create(:rating, post: post_first, value: 2)
      create(:rating, post: post_second, value: 5)
      create(:rating, post: post_third, value: 1)
      create(:rating, post: post_fourth, value: 5)
      request
    end

    context 'when successful request' do
      let(:n) { 3 }

      it_behaves_like "a successful request status"

      it('returns n posts') { expect(json_response.count).to be(3) }

      it 'returns top n posts ordered by average_rating DESC' do
        expect(json_response.first['title']).to eql('second post with rate 5')
        expect(json_response.second['title']).to eql('fourth post with rate 5')
        expect(json_response.third['title']).to eql('first post with rate 2')
      end

      it('returns only id, title and body') { expect(json_response.first.keys).to include('id', 'title', 'body') }

      it('does not return average_rating, ip and user_id') { expect(json_response.first.keys).not_to include('average_rating', 'ip', 'user_id') }
    end

    context 'when n is zero' do
      let(:n) { 0 }

      it_behaves_like "a bad request status"

      it('returns error message') { expect(json_response["error"]).to eql('N must be a positive integer.') }
    end
  end
end
