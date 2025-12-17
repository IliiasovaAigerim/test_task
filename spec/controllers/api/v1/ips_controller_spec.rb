# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::IpsController", type: :request do
  describe '#multiple_authors' do
    let(:json_response) { JSON.parse(response.body) }

    before do
      create(:post, ip: "8.8.8.8")
      n.times { create(:post, ip: "1.2.3.4") }
      get "/api/v1/ips", headers: { "Content-Type" => "application/json" }
    end

    shared_examples ':ok status code' do
      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when there are multiple authors with same ips' do
      let(:n) { 2 }

      it_behaves_like  ":ok status code"

      it 'returns correct ip' do
        expect(json_response.first["ip"]).to eql("1.2.3.4")
      end

      it 'returns correct number of logins' do
        expect(json_response.first["login"].count).to be(2)
      end

      it 'does not return ip with single author' do
        expect(json_response.all? { |e| e["login"].size > 1 }).to be_truthy
      end
    end

    context 'when there are no authors with same ips' do
      let(:n) { 1 }

      it_behaves_like ":ok status code"

      it 'returns empty array' do
        expect(json_response).to eq([])
      end
    end
  end
end

