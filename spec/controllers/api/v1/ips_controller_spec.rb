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

    context 'when there are multiple authors with same ips' do
      let(:n) { 2 }

      it_behaves_like "a successful request status"

      it('returns correct ip') { expect(json_response.first["ip"]).to eql("1.2.3.4") }

      it('returns correct number of logins') { expect(json_response.first["login"].count).to be(2) }

      it('does not return ip with single author') { expect(json_response).to all(have_attributes(size: be > 1)) }
    end

    context 'when there are no authors with same ips' do
      let(:n) { 1 }

      it_behaves_like "a successful request status"

      it('returns empty array') { expect(json_response).to eql([]) }
    end
  end
end
