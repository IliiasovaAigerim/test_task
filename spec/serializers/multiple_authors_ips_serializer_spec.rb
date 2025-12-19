# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MultipleAuthorsIpsSerializer do
  describe '#as_json' do
    subject { described_class.new(input_data).as_json }

    context 'when input is present' do
      let(:input_data) do
        {
          "192.168.1.1" => ["user1@test.com", "user2@test.com"],
          "10.0.0.5"    => ["user3@test.com", "user4@test.com"]
        }
      end

      it 'returns an array of hashes' do
        expect(subject).to be_an(Array)
        expect(subject.first).to be_a(Hash)
      end

      it 'correctly maps IP addresses and logins' do
        expect(subject).to contain_exactly(
                             { ip: '192.168.1.1', login: ["user1@test.com", "user2@test.com"] },
                             { ip: '10.0.0.5', login: ["user3@test.com", "user4@test.com"] }
                           )
      end
    end

    context 'when input is empty' do
      let(:input_data) { {} }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end
  end
end
