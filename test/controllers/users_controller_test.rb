require 'test_helper'

describe UsersController do
  
  describe '#receive_sms' do

    let(:coach) {create(:coach)}
    let(:user) {create(:user)}
    let(:task) {create(:task)}
    let(:post_params) {{"To" => coach.tel, "From" => user.tel, "Body" => "done"}}

    it "should save the incoming post" do
      post :receive_sms, post_params 

      Post.where(sender: user, recipient: coach).count.must_equal(1)
    end

    it "should create response" do
      task
      post :receive_sms, post_params

      Post.where(sender: coach, recipient: user).count.must_equal(1)
    end

    let(:task2) {create(:task)}
 
    it "TEMP response with down" do
      tasks = [task, task2] # initialize tasks 
      post :receive_sms, post_params
      responses = Post.where(sender: coach, recipient: user)
      responses.count.must_equal(1)
      responses.first.text.must_include "Nice job"
      skip("modularize response! -- this will fail when interpretation is better")
    end
  end
end
