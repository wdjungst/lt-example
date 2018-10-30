require 'rails_helper'

RSpec.describe "LoadTests", type: :request, load: true do
  describe "GET /load_tests" do
    it "works! (now write some real specs)" do
      get load_tests_path
      expect(response).to have_http_status(200)
    end
  end
end
