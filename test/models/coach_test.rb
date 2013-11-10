require 'test_helper'

describe 'Coach' do
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

    it 'returns intent of 1 when #create_task_for_user truthy' do
      coach.expects(:create_task_for_user).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 1
    end

    it 'returns intent of 2 when #create_epic_for_user truthy' do
      coach.expects(:create_epic_for_user).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 2
    end

    it 'returns intent of 3 when #show_epics_for_user truthy' do
      coach.expects(:show_epics_for_user).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 3
    end

    it 'returns intent of 4 when #show_epics_for_user truthy' do
      coach.expects(:show_epic_details).with(user, post).returns("msg")
      response, intent = coach.interpret(user, post)

      intent.must_equal 4
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