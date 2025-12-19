require 'rails_helper'

RSpec.describe "Api::V1::RatingsController", type: :request do
  describe "#create" do
    let(:headers) { { "Content-Type" => "application/json" } }
    let(:request) { post '/api/v1/ratings', params: request_params, headers: headers }
    let(:user) { create(:user) }
    let(:new_post) { create(:post, user: user) }

    context 'when valid request params' do
      let(:request_params) do
        {
          post_id: new_post.id,
          user_id: user.id,
          value: 4
        }.to_json
      end

      context 'when user rates post for the first time' do
        it_behaves_like "a created request status"

        it 'successfully creates rating' do
          new_post

          expect { request }.to change(Rating, :count).by(1)
        end

        it 'returns new average rating of the post' do
          new_post
          request

          json_response = JSON.parse(response.body)
          expect(json_response["average_rating"]).to be(4.0)
        end
      end

      context 'when multiple users rate the same post' do
        before do
          request
          post '/api/v1/ratings', params: { post_id: new_post.id, user_id: create(:user).id, value: 2  }.to_json, headers: headers
        end

        it 'calculates average rating correctly' do
          json_response = JSON.parse(response.body)
          expect(json_response["average_rating"]).to be(3.0)
        end
      end

      context 'when user rates post for the second time' do
        before do
          new_post
          create(:rating, post: new_post, user: user, value: 5)
        end

        it_behaves_like "an unprocessable request status"

        it('fails to create rating') { expect { request }.not_to change(Rating, :count) }

        it 'returns message' do
          request
          json_response = JSON.parse(response.body)
          expect(json_response["errors"][0]).to eql("User has already rated this post")
        end
      end
    end

    context 'when invalid request params' do
      let(:request_params) do
        {
          post_id: post_id,
          user_id: user_id,
          value: value
        }.to_json
      end

      before { request }

      context 'when invalid value' do
        let(:user_id) { user.id }
        let(:post_id) { new_post.id }

        shared_examples "error message" do
          it 'returns invalid value error message' do
            json_response = JSON.parse(response.body)
            expect(json_response['errors'][0]).to eql("Value must be in 1..5")
          end
        end

        context 'when value is > 5' do
          let(:value) { 6 }

          it_behaves_like "an unprocessable request status"
          it_behaves_like "error message"
        end

        context 'when value is < 1' do
          let(:value) { 0 }

          it_behaves_like "an unprocessable request status"
          it_behaves_like "error message"
        end
      end

      context 'when trying to rate non-existent post' do
        let(:post_id) { -1 }
        let(:user_id) { user.id }
        let(:value) { 5 }

        it_behaves_like "a not found request status"

        it 'returns error message' do
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eql("Post not found")
        end
      end

      context 'when non-existent user' do
        let(:post_id) { new_post.id }
        let(:user_id) { -1 }
        let(:value) { 5 }

        it_behaves_like "an unprocessable request status"

        it 'returns error message' do
          json_response = JSON.parse(response.body)
          expect(json_response['errors'][0]).to eql("User must exist")
        end
      end
    end
  end
end
