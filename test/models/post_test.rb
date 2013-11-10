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
  
  describe '::Intents' do
    it 'is a hash' do
      assert Post::Intents.instance_of? Hash
    end

    it '::Intents[:coach][:completed_todays_goal] returns 0' do
      Post::Intents[:coach][:completed_todays_goal].must_equal 0
    end

    it 'never repeats values' do
      coach_values = Post::Intents[:coach].values
      user_values = Post::Intents[:user].values
      all_values  = coach_values + user_values

      all_values.count.must_equal all_values.uniq.count
    end
  end

  describe '.save_sms' do

    let(:sender) {create(:coach)}
    let(:recipient) {create(:user)}
    let(:text) {"message"}
    let(:intent) {1}

    it "saves sender" do
      post = Post.save_sms sender, recipient, text, intent

      post.sender.must_equal sender
    end

    it "saves recipient" do
      post = Post.save_sms sender, recipient, text, intent

      post.recipient.must_equal recipient
    end

    it "saves text" do
      post = Post.save_sms sender, recipient, text, intent

      post.text.must_equal text
    end
  end
end