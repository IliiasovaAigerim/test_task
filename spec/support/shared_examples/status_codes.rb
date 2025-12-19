RSpec.shared_examples "a successful request status" do
  it "returns status 200" do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples "a bad request status" do
  it "returns status 400" do
    expect(response).to have_http_status(:bad_request)
  end
end

RSpec.shared_examples "a created request status" do
  it "returns status 201" do
    request

    expect(response).to have_http_status(:created)
  end
end

RSpec.shared_examples "an unprocessable request status" do
  it "returns status 422" do
    request
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

RSpec.shared_examples "a not found request status" do
  it "returns status 404" do
    expect(response).to have_http_status(:not_found)
  end
end