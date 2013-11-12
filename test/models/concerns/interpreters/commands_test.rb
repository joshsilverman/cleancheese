require 'test_helper'
include Commands

describe Commands do
  describe '#complete_todays_goal' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}

    it 'responds with "need more goals if no goals"' do
      incoming_message = build(:post, text: 'done')

      coach.stubs(:todays_goal).returns(nil)
      outgoing_message = coach.complete_todays_goal user, incoming_message

      outgoing_message.must_equal "Looks like you need to add more goals."
    end

    it 'responds with "nice job" if more goals' do
      next_task = build(:task)
      incoming_message = build(:post, text: 'done')

      coach.stubs(:todays_goal).returns(next_task)
      outgoing_message = coach.complete_todays_goal user, incoming_message

      outgoing_message.must_equal "Nice job"
    end

    it 'does not return false when "dOnE" is capitalized' do
      next_task = stub(update: true)
      coach.stubs(todays_goal: next_task)
      incoming_message = build(:post, text: 'dOnE')

      outgoing_message = coach.complete_todays_goal user, incoming_message

      outgoing_message.wont_equal false
    end

    it 'updates goal as complete with completed_at' do
      Timecop.freeze
      todays_goal_mock = mock()
      todays_goal_mock.expects('update')\
              .with(complete: true, completed_at: Time.now)\
              .returns(true)
      incoming_message = build(:post, text: 'done')

      coach.stubs(:todays_goal).returns(todays_goal_mock)

      outgoing_message = coach.complete_todays_goal user, incoming_message
    end
  end

  describe '#create_task' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}

    it 'returns false if incoming message does not begin with post' do

      incoming_message = build(:post, text: 'bo go to store')

      coach.create_task(user, incoming_message).must_equal false
      Task.count.must_equal 0
    end

    it 'returns task name if incoming message begins with do' do
      incoming_message = build(:post, text: 'do go to store')

      incoming_message.tasks.expects(:create).returns(true)
      new_task_name = coach.create_task(user, incoming_message)

      new_task_name.must_equal 'I just added a new task: go to store'
    end

    it 'returns task name if incoming message begins with do (case insensitive)' do
      incoming_message = build(:post, text: 'Do go to store')

      incoming_message.tasks.expects(:create).returns(true)
      new_task_name = coach.create_task(user, incoming_message)

      new_task_name.must_equal 'I just added a new task: go to store'
    end

    it 'creates new task for user with no date' do
      incoming_message = create(:post, text: 'do go to store')

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_equal nil
    end

    it 'creates new task for user with a date' do
      incoming_message = create(:post, text: 'do go to store tomorrow')

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_be_kind_of Time
    end

    it 'creates new task that belongs to post' do
      incoming_message = create(:post, text: 'do go to store')

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.post_id.must_equal incoming_message.id
    end
  end

  describe '#create_epic' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'returns false if cannot interpret' do
      incoming_post.text = 'asdf'

      response = coach.create_epic user, incoming_post

      response.must_equal false
    end

    it 'returns success message if can interpret' do
      incoming_post.text = 'new epic Healthcare'

      response = coach.create_epic user, incoming_post
      
      response.must_equal "I created a new epic: Healthcare"
    end

    it 'creates a new epic for user' do
      incoming_post.text = 'new epic Healthcare'
      user.id = 123

      Epic.expects(:create).with(name: 'Healthcare', user_id: user.id)

      coach.create_epic user, incoming_post
    end

    it 'creates a new epic for user (case insensitive)' do
      incoming_post.text = 'NeW EpIc Healthcare'
      user.id = 123

      Epic.expects(:create).with(name: 'Healthcare', user_id: user.id)

      coach.create_epic user, incoming_post
    end
  end

  describe '#show_epics' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'returns false if cannot interpret' do
      incoming_post.text = 'asdf'

      response = coach.show_epics user, incoming_post

      response.must_equal false
    end

    it 'returns list of epics if can interpret' do
      incoming_post.text = 'show epics'
      user.epics << Epic.new(name: 'Healthcare')
      user.epics.stubs(:visible).returns(user.epics)

      response = coach.show_epics user, incoming_post
      
      response.must_include "Epics:\n (1) Healthcare"
    end

    it 'returns list of epics excluding hidden epics' do
      incoming_post.text = 'show epics'
      user.save
      user.epics << Epic.create(name: 'Healthcare')
      user.epics << Epic.create(name: 'hidden epic', hidden: true)

      response = coach.show_epics user, incoming_post
      
      response.wont_include 'hidden epic'
    end

    it 'returns list of epics with actions if can interpret' do
      incoming_post.text = 'show epics'
      user.epics << Epic.new(name: 'Healthcare')
      user.epics.stubs(:visible).returns(user.epics)

      response = coach.show_epics user, incoming_post
      
      expected_response = "Epics:\n (1) Healthcare\n\nReply '1','2' ... for options"
      response.must_equal expected_response
    end
  end

  describe '#show_epic_details' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'return false if no last coach post' do
      response = coach.show_epic_details user, incoming_post

      response.must_equal false
    end

    it 'returns false if last coach post not Post::Intents[:coach][:showed_epics]' do
      posts_stub = stub()
      posts_stub.stubs(:order).returns([Post.new])
      Post.stubs(:where).returns posts_stub

      response = coach.show_epic_details user, incoming_post

      response.must_equal false
    end

    it 'returns false if incoming_post text not integer' do
      posts_stub = stub()
      posts_stub.stubs(:order).returns([Post.new(intent: Post::Intents[:coach][:showed_epics])])
      Post.stubs(:where).returns posts_stub

      response = coach.show_epic_details user, incoming_post

      response.must_equal false
    end

    it 'returns msg with epic details if last coach post with correct intent' do
      posts_stub = stub()
      posts_stub.stubs(:order).returns([Post.new(intent: Post::Intents[:coach][:showed_epics])])
      Post.stubs(:where).returns posts_stub

      Epic.create(name: 'Healthcare', user: user)
      incoming_post.text = '1'
      partial_expected_response = "Healthcare Epic Options:"

      response = coach.show_epic_details user, incoming_post

      response.must_include partial_expected_response
    end

    it 'ignores hidden epics when finding correct epic' do
      skip "implement"
    end

    it 'returns msg with options if last coach post with correct intent' do
      posts_stub = stub()
      posts_stub.stubs(:order).returns([Post.new(intent: Post::Intents[:coach][:showed_epics])])
      Post.stubs(:where).returns posts_stub

      Epic.create(name: 'Healthcare', user: user)
      incoming_post.text = '1'
      partial_expected_response = "Reply '1' to hide"

      response = coach.show_epic_details user, incoming_post

      response.must_include partial_expected_response
    end

    it 'associates msg with user request' do
      posts_stub = stub()
      posts_stub.stubs(:order).returns([Post.new(intent: Post::Intents[:coach][:showed_epics])])
      Post.stubs(:where).returns posts_stub

      epic = Epic.create(name: 'Healthcare', user: user)
      incoming_post.text = '1'
      partial_expected_response = "Reply '1' to hide"

      response = coach.show_epic_details user, incoming_post

      incoming_post.epic.must_equal epic
    end
  end

  describe '#hide_epic' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'returns false unless last coach post was showing an epic' do
      response = coach.hide_epic user, incoming_post

      response.must_equal false
    end

    it 'returns false if user does not provide "1"' do
      posts_stub = stub()
      last_coach_post = Post.new(intent: Post::Intents[:coach][:hide_epic])
      posts_stub.stubs(:order).returns([last_coach_post])
      Post.stubs(:where).returns posts_stub

      incoming_post.text = 'abc'
      response = coach.hide_epic user, incoming_post

      response.must_equal false
    end

    it 'returns false if no epic to hide' do
      posts_stub = stub()
      last_coach_post = Post.new(intent: Post::Intents[:coach][:showed_epic_details])
      posts_stub.stubs(:order).returns([last_coach_post])
      Post.stubs(:where).returns posts_stub

      incoming_post.text = '1'
      coach.hide_epic(user, incoming_post).must_equal false
    end

    it 'updates epic to hidden if user provides "1"' do
      coach_posts_stub = stub()
      last_coach_post = Post.new(intent: Post::Intents[:coach][:showed_epic_details])
      coach_posts_stub.stubs(:order).returns([last_coach_post])
      Post.stubs(:where).with(sender: coach, recipient: user).returns coach_posts_stub

      user_posts_stub = stub()
      epic = Epic.new(name: "Abc Epic")
      last_user_post = Post.new(text: 'message', epic: epic)

      user_posts = stub()
      user_posts.expects(:[]).returns(last_user_post)
      user_posts_stub.stubs(:order).returns(user_posts)
      Post.stubs(:where).with(sender: user, recipient: coach).returns user_posts_stub

      epic.expects(:update).with(hidden: true)
      incoming_post.text = '1'

      coach.hide_epic user, incoming_post
    end

    it 'returns "I hide epic_name" if epic found' do
      coach_posts_stub = stub()
      last_coach_post = Post.new(intent: Post::Intents[:coach][:showed_epic_details])
      coach_posts_stub.stubs(:order).returns([last_coach_post])
      Post.stubs(:where).with(sender: coach, recipient: user).returns coach_posts_stub

      user_posts_stub = stub()
      epic = Epic.new(name: "Abc Epic")
      last_user_post = Post.new(text: 'message', epic: epic)

      user_posts = stub()
      user_posts.expects(:[]).returns(last_user_post)
      user_posts_stub.stubs(:order).returns(user_posts)
      Post.stubs(:where).with(sender: user, recipient: coach).returns user_posts_stub

      incoming_post.epic = epic
      incoming_post.text = '1'

      response = coach.hide_epic user, incoming_post

      response.must_include "OK, I hid #{epic.name}"
    end
  end
end