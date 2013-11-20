require 'test_helper'

describe 'Coach' do
  
  describe '#send_todays_goal' do
    let(:user) { build :user }
    let(:coach) { build :coach }
    let(:todays_goal) { build :task }

    it 'returns a post' do
      coach.expects(:todays_goal).returns(todays_goal)

      response = coach.send_todays_goal user
      response.must_be_kind_of Post
    end

    it 'creates a post with correct intent' do
      expected_intent = Post::Intents[:coach][:sending_todays_goal]
      coach.stubs(:todays_goal).returns(todays_goal)

      response = coach.send_todays_goal user

      refute_nil(expected_intent)
      response.must_be_kind_of Post
    end
  end

  describe '#send_reminder' do
    let(:user) { build :user }
    let(:coach) { build :coach }
    let(:todays_goal) { build :task }

    it 'returns a post' do
      coach.expects(:todays_goal).returns(todays_goal)

      response = coach.send_reminder user
      response.must_be_kind_of Post
    end

    it 'creates a post with correct intent' do
      expected_intent = Post::Intents[:coach][:reminding_todays_goal]
      coach.stubs(:todays_goal).returns(todays_goal)

      response = coach.send_reminder user

      refute_nil(expected_intent)
      response.must_be_kind_of Post
    end
  end

  describe '#respond' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_message) {build(:post)}

    it 'calls sms with message' do
      incoming_message.text = 'done'

      response = 'response text'
      coach.expects(:interpret).returns([response, 1])
      coach.expects(:sms).with(user, response, 1).returns(build(:post))
      outgoing_message = coach.respond user, incoming_message

      outgoing_message.must_be_kind_of Post
    end

    it 'calls sms with intent' do
      incoming_message.text = 'done'

      response = 'response text'
      coach.expects(:interpret).returns([response, 1])
      coach.expects(:sms).with(user, response, 1).returns(build(:post))
      outgoing_message = coach.respond user, incoming_message

      outgoing_message.must_be_kind_of Post
    end

    it 'returns false if message cannot be interpreted' do
      incoming_message.text = 'still working...'

      coach.respond(user, incoming_message).must_equal false
    end
  end

  describe '#interpret' do
    let(:coach) { build(:coach) }
    let(:user) { build(:user) }
    let(:post) { build(:post) }

    it 'returns false if nothing actionable' do
      skip "must figure out how to mock coach actions to test"
    end

    it 'returns intent and response if something actionable' do
      coach.expects(:complete_todays_goal).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      response.must_be_kind_of String
      intent.must_be_kind_of Integer
    end

    it 'returns intent of 0 when #complete_todays_goal truthy' do
      coach.expects(:complete_todays_goal).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 0
    end

    it 'returns intent of 1 when #create_task truthy' do
      coach.expects(:create_task).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 1
    end

    it 'returns intent of 2 when #create_epic truthy' do
      coach.expects(:create_epic).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 2
    end

    it 'returns intent of 3 when #show_epics truthy' do
      coach.expects(:show_epics).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 3
    end

    it 'returns intent of 4 when #show_epics truthy' do
      coach.expects(:show_epic_details).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 4
    end

    it 'returns intent of 5 when #hide_epic truthy' do
      coach.expects(:hide_epic).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 5
    end

    it 'returns intent of 6 when #select_abbreviation_option truthy' do
      coach.expects(:select_abbreviation_option).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 6
    end

    it 'returns intent of 7 when #abbreviate_epic truthy' do
      coach.expects(:abbreviate_epic).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 7
    end

    it 'returns intent of 10 when #show_tasks truthy' do
      coach.expects(:show_tasks).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 10
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