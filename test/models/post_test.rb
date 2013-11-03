require 'test_helper'

describe 'PostTest' do

  describe '#has_many :tasks' do
    let(:task) {build(:task)}
    let(:post) {build(:post)}

    it 'is valid if no tasks associated' do
      task.valid?.must_equal true
    end

    it 'is valid if tasks associated' do
      post.tasks = [task]

      post.tasks.wont_be_empty
      post.valid?.must_equal true
    end
  end
  
  describe '.save_sms' do

    let(:sender) {create(:coach)}
    let(:recipient) {create(:user)}
    let(:text) {"message"}

    before :each do
      @post = Post.save_sms sender, recipient, text
    end

    it "saves sender" do
      @post.sender.must_equal sender
    end

    it "saves recipient" do
      @post.recipient.must_equal recipient
    end

    it "saves text" do
      @post.text.must_equal text
    end
  end
end