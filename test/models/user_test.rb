require 'test_helper'

describe 'User' do

  describe '#tasks' do
    it 'must save tasks' do
      task = Task.create
      user = User.create

      user.tasks << task

      user.tasks.first.must_equal task
    end
  end

  describe '#prev_post_to' do
    let(:coach) { build :coach }
    let(:user) { build :user }

    it 'returns false if no prev post to user' do
      prev_post_to_user = coach.prev_post_to user
      prev_post_to_user.must_equal nil
    end

    it 'returns prev post to user if exists' do
      coach.save
      expected_prev_post = Post.create(sender: coach, text: 'message')

      prev_post_to_user = coach.prev_post_to user

      prev_post_to_user.must_equal expected_prev_post
    end

    it 'returns prev post to user if exists' do
      coach.save
      expected_prev_post = Post.create(sender: coach, text: 'message')

      prev_post_to_user = coach.prev_post_to user

      prev_post_to_user.must_equal expected_prev_post
    end

    it 'returns prev-prev post to user if passed index of 1' do
      coach.save
      expected_prev_post = Post.create(sender: coach, text: 'message')
      Post.create(sender: coach, text: 'message')

      prev_post_to_user = coach.prev_post_to user, 1

      prev_post_to_user.must_equal expected_prev_post
    end
  end

  describe '#prev_intent_to' do
    let(:coach) { build(:coach) }
    let(:user) { build(:user) }

    it 'returns false if no previous post to user' do
      coach.prev_intent_to(user).must_equal nil
    end

    it 'returns false if previous post to user has no intent' do
      Post.create(sender:coach, recipient: user)
      coach.prev_intent_to(user).must_equal nil
    end

    it 'returns 1 if previous post to user has intent 1' do
      Post.create(sender:coach, recipient: user, intent: 1)
      coach.prev_intent_to(user).must_equal 1
    end

    it 'returns 2 if 2 posts ago has intent 2 and offset 1 passted' do
      Post.create(sender:coach, recipient: user, intent: 2)
      Post.create(sender:coach, recipient: user, intent: 1)
      coach.prev_intent_to(user, 1).must_equal 2
    end
  end

  describe '#has_many :epics' do
    it 'is valid without epics' do
      user = User.new

      user.valid?.must_equal true
    end

    it 'is valid with epics' do
      user = User.create
      epic = Epic.create

      epic.user = user
      epic.save

      user.epics.empty?.wont_equal true
      user.valid?.must_equal true
    end
  end

  describe '#sms' do
    let(:coach) {build :coach}
    let(:user) {build :user}
    let(:message) {"sample message"}
    let(:intention) {1}

    it 'returns post' do
      Post.expects(:save_sms).with(coach, user, message, intention)\
              .returns(Post.new)

      response = coach.sms(user, message, intention)

      assert response.instance_of?(Post) # was unable to use typical expectation
    end
  end

  describe '#todays_goal' do
    it 'returns goal if incomplete one exists' do
      skip('INC')
    end

    it 'returns nil if incomplete doesnt exists' do
      skip('INC')
    end
  end
end