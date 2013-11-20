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

    it 'wont error with long text' do
      text = "abc" * 1000
      post = Post.save_sms sender, recipient, text, intent

      post.text.must_equal text
    end
  end

  describe '#match_on_abbrev' do
    let(:user) { create(:user) }
    let(:post) { build(:post, text: 'HC do it') }

    it 'returns false if no sender' do
      post.match_on_abbrev.must_equal false
    end

    it 'returns a match object if there is an abbreviation match' do
      post.sender = user
      epic = build(:epic, user: user, abbreviation: 'HC')
      user.epics << epic

      post.match_on_abbrev.must_be_kind_of MatchData
    end

    it 'returns a match object with HC at first subscript' do
      post.sender = user
      epic = build(:epic, user: user, abbreviation: 'HC')
      user.epics << epic

      post.match_on_abbrev[1].must_equal 'HC'
    end

    it 'returns a match object with HC at first subscript' do
      post.sender = user
      epic = build(:epic, user: user, abbreviation: 'HC')
      user.epics << epic

      post.match_on_abbrev[2].must_equal 'do it'
    end
  end
end