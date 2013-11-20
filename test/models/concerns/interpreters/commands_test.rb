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

  describe '#show_tasks' do
    let(:coach) {build(:coach)}
    let(:user) {build(:user)}
    let(:incoming_post) {build(:post)}

    it 'returns false if cannot interpret' do
      incoming_post.text = 'asdf'

      response = coach.show_tasks user, incoming_post

      response.must_equal false
    end

    it 'wont return false if givin "tasks"' do
      incoming_post.text = 'tasks'
      user.tasks.stubs(:visible).returns(user.tasks)

      response = coach.show_tasks user, incoming_post
      
      response.wont_equal false
    end

    it 'returns list of tasks if givin "tasks"' do
      incoming_post.text = 'tasks'
      user.save
      user.tasks << Task.create(name: 'task')

      response = coach.show_tasks user, incoming_post
      
      response.must_include 'Tasks:'
      response.must_include '(1) task'
    end

    it 'returns list of tasks excluding non-active tasks' do
      incoming_post.text = 'tasks'

      user.save
      user.tasks << Task.create(name: 'task')
      task2 = Task.create(name: 'task2', complete: true)
      user.tasks << task2
      task2.update(updated_at: 10.days.ago)

      response = coach.show_tasks user, incoming_post
      
      response.wont_include 'task2'
    end

    it 'returns list of tasks with actions if can interpret' do
      incoming_post.text = 'tasks'
      
      user.save
      user.tasks << Task.create(name: 'task')

      response = coach.show_tasks user, incoming_post
      
      expected_actions = "Reply '1','2' ... for options"
      response.must_include expected_actions
    end
  end

  describe '#create_task' do
    let(:coach) {build(:coach)}
    let(:user) {create(:user)}
    let(:incoming_message) { create(:post, sender: user) }

    it 'returns false if incoming message does not begin with post' do
      incoming_message.text = 'bo go to store'

      coach.create_task(user, incoming_message).must_equal false
      Task.count.must_equal 0
    end

    it 'returns task name if incoming message begins with do' do
      incoming_message.text = 'do go to store'

      Task.expects(:create).returns(Task.new)
      new_task_name = coach.create_task(user, incoming_message)

      new_task_name.must_equal 'I just added a new task: go to store'
    end

    it 'returns task name if incoming message begins with do (case insensitive)' do
      incoming_message.text = 'Do go to store'

      Task.expects(:create).returns(Task.new)
      new_task_name = coach.create_task(user, incoming_message)

      new_task_name.must_equal 'I just added a new task: go to store'
    end

    it 'creates new task for user with no date' do
      incoming_message.text = 'do go to store'

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_equal nil
    end

    it 'creates new task for user with a date' do
      incoming_message.text = 'do go to store tomorrow'

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.name.must_equal 'go to store'
      new_task.complete_by.must_be_kind_of Time
    end

    it 'creates new task that belongs to post' do
      incoming_message.text = 'do go to store'

      coach.create_task(user, incoming_message)
      new_task = Task.last

      new_task.post_id.must_equal incoming_message.id
    end

    it 'returns false if leading abbreviation does not exist' do
      incoming_message.text = 'HC create account'

      response = coach.create_task(user, incoming_message)
      
      response.must_equal false
    end

    it 'associates new task with epic if abbreviation exists' do
      epic = Epic.create(user: user, abbreviation: 'HC')
      incoming_message.text = 'HC create account'

      coach.create_task(user, incoming_message)

      Task.last.epic.must_equal epic
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

    it 'returns list of epics if give "show epics"' do
      incoming_post.text = 'show epics'
      user.epics << Epic.new(name: 'Healthcare')
      user.epics.stubs(:visible).returns(user.epics)

      response = coach.show_epics user, incoming_post
      
      response.must_include "Epics:\n (1) Healthcare"
    end

    it 'returns list of epics if givin "epics"' do
      incoming_post.text = 'epics'
      user.epics.stubs(:visible).returns(user.epics)

      response = coach.show_epics user, incoming_post
      
      assert(response)
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
      
      expected_response = "Epics:\n (1) Healthcare\n\n\nReply '1','2' ... for options"
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
      coach.expects(:prev_intent_to).with(user)\
            .returns Post::Intents[:coach][:showed_epics]

      response = coach.show_epic_details user, incoming_post

      response.must_equal false
    end

    it 'returns false if incoming_post text not integer' do
      coach.stubs(:prev_intent_to).with(user)\
            .returns Post::Intents[:coach][:showed_epics]

      response = coach.show_epic_details user, incoming_post

      response.must_equal false
    end

    it 'returns msg with epic details if last coach post with correct intent' do
      coach.stubs(:prev_intent_to).with(user)\
            .returns Post::Intents[:coach][:showed_epics]

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
      coach.stubs(:prev_intent_to).with(user)\
            .returns Post::Intents[:coach][:showed_epics]

      Epic.create(name: 'Healthcare', user: user)
      incoming_post.text = '1'
      partial_expected_response = "Reply '1' to hide"

      response = coach.show_epic_details user, incoming_post

      response.must_include partial_expected_response
    end

    it 'associates msg with user request' do
      coach.stubs(:prev_intent_to).with(user)\
            .returns Post::Intents[:coach][:showed_epics]

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
    let(:incoming_post) {build(:post, sender: user, recipient: coach)}

    it 'returns false unless last coach post was showing an epic' do
      response = coach.hide_epic user, incoming_post

      response.must_equal false
    end

    it 'returns false if user does not provide "1"' do
      coach.save
      last_coach_post = Post.create(intent: Post::Intents[:coach][:showed_epic_details],
                                    sender: coach)

      incoming_post.text = 'abc'
      response = coach.hide_epic user, incoming_post

      response.must_equal false
    end

    it 'returns false if no epic to hide' do
      coach.save
      last_coach_post = Post.create(intent: Post::Intents[:coach][:showed_epic_details],
                                    sender: coach)

      incoming_post.text = '1'
      coach.hide_epic(user, incoming_post).must_equal false
    end

    it 'updates epic to hidden if user provides "1"' do
      coach.save
      last_coach_post = Post.create(intent: Post::Intents[:coach][:showed_epic_details],
                                    sender: coach,
                                    recipient: user)

      last_user_post = Post.create(text: 'message', sender: user, recipient: coach)
      epic = Epic.create(name: "Abc Epic", post: last_user_post, user: user)
      incoming_post.save

      incoming_post.text = '1'
      coach.hide_epic user, incoming_post

      epic.reload.hidden.must_equal true
    end

    it 'returns "I hide epic_name" if epic found' do
      coach.save
      last_coach_post = Post.create(intent: Post::Intents[:coach][:showed_epic_details],
                                    sender: coach,
                                    recipient: user)

      last_user_post = Post.create(text: 'message', sender: user, recipient: coach)
      epic = Epic.create(name: "Abc Epic", post: last_user_post, user: user)
      incoming_post.save

      incoming_post.text = '1'
      response = coach.hide_epic user, incoming_post

      response.must_include "OK, I hid #{epic.name}"
    end
  end

  describe '#select_abbreviation_option' do
    let(:coach) { build(:coach) }
    let(:user) { build(:user) }
    let(:incoming_post) { build(:post) }

    it 'can only be selected if prev intent to user was :showed_epic_details' do
      response = coach.select_abbreviation_option user, incoming_post
      response.must_equal false
    end

    it 'returns false if 2 not passed' do
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:showed_epic_details]
      incoming_post.text = '1'

      response = coach.select_abbreviation_option user, incoming_post
      response.must_equal false
    end

    it 'returns false if no epic selected' do
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:showed_epic_details]
      incoming_post.text = '2'

      response = coach.select_abbreviation_option user, incoming_post
      response.must_equal false
    end


    it 'returns "How would you like to abbreviate \'Healthcare\'?" when selected' do
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:showed_epic_details]
      coach.stubs(:selected_epic_for).returns Epic.new name: 'Healthcare'
      incoming_post.text = '2'

      response = coach.select_abbreviation_option user, incoming_post
      response.must_equal "How would you like to abbreviate 'Healthcare'?"
    end

    it 'sets the epic id on the incoming_post' do
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:showed_epic_details]
      user.save
      epic = Epic.create name: 'Healthcare', user: user
      coach.stubs(:selected_epic_for).returns epic
      incoming_post.text = '2'
      incoming_post.save

      response = coach.select_abbreviation_option user, incoming_post
      incoming_post.reload.epic.must_equal epic
    end
  end

  describe '#abbreviate_epic' do
    let(:user) { create(:user) }
    let(:coach) { create(:coach) }
    let(:incoming_post) { create(:post, sender: user, recipient: coach) }

    it 'returns false if previous intent of coach not :showed_epic_details' do
      create(:post, sender: coach, recipient: user)

      response = coach.abbreviate_epic user, incoming_post

      response.must_equal false
    end

    it 'returns false if no epic selected' do 
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:showed_epic_details]
      incoming_post.save
      prev_post_to_coach = create(:post, sender: user, recipient: coach)

      response = coach.abbreviate_epic user, incoming_post

      response.must_equal false
    end


    it 'updates abbreviation on epic' do 
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:solicit_abbreviation]
      prev_post_to_coach_offset_1 = create(:post, sender: user, recipient: coach)
      
      epic = create(:epic, user: user)
      prev_post_to_coach_offset_1.epic = epic

      incoming_post.text = 'HC'
      incoming_post.save

      response = coach.abbreviate_epic user, incoming_post

      epic.reload.abbreviation.must_equal "HC"
    end

    it 'returns confirmation when epic abbreviated' do 
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:solicit_abbreviation]
      prev_post_to_coach_offset_1 = create(:post, sender: user, recipient: coach)
      
      epic = create(:epic, user: user, name: 'Healthcare')
      prev_post_to_coach_offset_1.epic = epic

      incoming_post.text = 'HC'
      incoming_post.save

      response = coach.abbreviate_epic user, incoming_post

      response.must_equal "Ok, you can now refer to 'Healthcare' as 'HC'"
    end

    it 'ensure abbreviation not duplicate' do 
      coach.stubs(:prev_intent_to).returns Post::Intents[:coach][:solicit_abbreviation]
      prev_post_to_coach_offset_1 = create(:post, sender: user, recipient: coach)
      
      create(:epic, user: user, abbreviation: 'HC')
      epic = create(:epic, user: user, name: 'Healthcare')
      prev_post_to_coach_offset_1.epic = epic

      incoming_post.text = 'HC'
      incoming_post.save

      response = coach.abbreviate_epic user, incoming_post
      response.must_equal false
    end
  end
end