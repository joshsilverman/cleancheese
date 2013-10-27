require 'test_helper'

describe 'UsersControllerTest' do

  before :all do
    @routes = Rails.application.routes
  end
  
  describe 'receive_sms' do

    let(:coach) {create(:coach)}
    let(:user) {create(:user)}

    it "should save the post" do
      params = {"To" => coach.tel, "From" => user.tel, "Body" => "message"}
      post :receive_sms, params
      Post.where(from: user.id, to: coach.id).count.should eq(1)
    end

    it "should create response" do
      assert true
    end
  end
end
