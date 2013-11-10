require 'test_helper'

describe 'Coach' do
  describe '#respond' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_message) {build(:post)}

    it 'calls sms with message' do
      incoming_message.text = 'done'

      coach.expects(:interpret).returns('response text')
      coach.expects(:sms).returns(build(:post))
      outgoing_message = coach.respond user, incoming_message

      outgoing_message.must_be_kind_of Post
    end

    it 'returns false if message cannot be interpreted' do
      incoming_message.text = 'still working...'

      coach.respond(user, incoming_message).must_equal false
    end
  end

  describe '#interpret' do
    it 'returns false if nothing actionable' do
      skip "must figure out how to mock coach actions to test"
    end

    it 'returns string if something actionable' do
      coach = build(:coach)
      user = build(:user)
      post = build(:post)

      coach.expects(:complete_todays_goal).with(user, post).returns("msg")
      coach.interpret(user, post).must_be_kind_of String
    end
  end

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

  describe '#create_task_for_user' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}

    it 'returns false if incoming message does not begin with post' do

      incoming_message = build(:post, text: 'bo go to store')

      coach.create_task_for_user(user, incoming_message).must_equal false
      Task.count.must_equal 0
    end

    it 'returns task name if incoming message begins with do' do
      incoming_message = build(:post, text: 'do go to store')

      incoming_message.tasks.expects(:create).returns(true)
      new_task_name = coach.create_task_for_user(user, incoming_message)

      new_task_name.must_equal 'I just added a new task: go to store'
    end

    it 'creates new task for user with no date' do
      incoming_message = create(:post, text: 'do go to store')

      coach.create_task_for_user(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_equal nil
    end

    it 'creates new task for user with a date' do
      incoming_message = create(:post, text: 'do go to store tomorrow')

      coach.create_task_for_user(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_be_kind_of Time
    end

    it 'creates new task that belongs to post' do
      incoming_message = create(:post, text: 'do go to store')

      coach.create_task_for_user(user, incoming_message)
      new_task = Task.last

      new_task.post_id.must_equal incoming_message.id
    end

  end

  describe '#create_epic_for_user' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'returns false if cannot interpret' do
      incoming_post.text = 'asdf'

      response = coach.create_epic_for_user user, incoming_post

      response.must_equal false
    end

    it 'returns success message if can interpret' do
      incoming_post.text = 'new epic Healthcare'

      response = coach.create_epic_for_user user, incoming_post
      
      response.must_equal "I created a new epic: Healthcare"
    end

    it 'creates a new epic for user' do
      incoming_post.text = 'new epic Healthcare'
      user.id = 123

      Epic.expects(:create).with(name: 'Healthcare', user_id: user.id)

      coach.create_epic_for_user user, incoming_post
    end

  end

  describe '#interpret_msg_with_complete_by_str' do
    let(:coach) {build(:coach)}

    it 'returns msg and nil if no date found' do
      msg, date = coach.interpret_msg_with_complete_by_str('message')

      msg.must_equal 'message'
      date.must_equal nil
    end

    it 'returns msg and obj Time if for "task in three days"' do
      msg, date = coach.interpret_msg_with_complete_by_str "task in three days"

      msg.must_equal 'task'
      date.must_be_kind_of Time
    end
  end
end