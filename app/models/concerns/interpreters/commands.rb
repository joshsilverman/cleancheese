module Commands

  # @todo: move to TasksController
  def complete_todays_goal user, incoming_post
    return false unless incoming_post.text.downcase.include? "done"
    if todays_goal and todays_goal.update(complete: true, completed_at: Time.now)
      "Nice job"
    else
      "Looks like you need to add more goals."
    end
  end

  # @todo: move to TasksController
  def create_task user, incoming_post
    task_match = incoming_post.match_on_abbrev
    return false unless task_match

    task_name_with_complete_by_str = task_match[2]
    task_name, complete_by = 
      interpret_msg_with_complete_by_str(task_name_with_complete_by_str)

    new_task = Task.create(name: task_name, complete_by: complete_by)
    incoming_post.tasks << new_task

    abbreviation = task_match[1]
    epic = Epic.where(user: user, abbreviation: abbreviation).first
    new_task.update(epic: epic) if epic

    "I just added a new task: #{task_name}"
  end

  # @todo: move to EpicController
  def create_epic user, incoming_post
    new_epic_name_match = incoming_post.text.match(/^new epic (.+)/i)
    return false unless new_epic_name_match

    new_epic_name = new_epic_name_match[1]

    Epic.create(name: new_epic_name, user_id: user.id)

    "I created a new epic: #{new_epic_name}"
  end

  # @todo: move to EpicController
  def show_epics user, incoming_post
    text = incoming_post.text
    match = text.match(/^show epics/i) || text.match(/^epics$/i)
    return false unless match

    response = "Epics:\n"
    
    user.epics.visible.each_with_index do |epic, i|
      response += " (#{i+1}) #{epic.name}#{" [#{epic.abbreviation}]" if epic.abbreviation}\n"
    end
    response += "\n\nReply '1','2' ... for options"

    response
  end

  # @todo: move to EpicController
  def show_epic_details user, incoming_post
    prev_intent_of_coach = self.prev_intent_to user
    return false unless prev_intent_of_coach ==  Post::Intents[:coach][:showed_epics]

    epic_index = incoming_post.text.to_i - 1
    return false unless epic_index >= 0

    epic = user.epics.visible.offset(epic_index).first
    return false unless epic
    incoming_post.update(epic: epic)
    
    actions = "\n\nReply '1' to hide\nReply '2' to abbreviate"

    "#{epic.name} Epic Options:" + actions
  end

  # @todo: move to EpicController
  def hide_epic user, incoming_post
    return false unless self.prev_intent_to(user) ==  Post::Intents[:coach][:showed_epic_details]
    return false unless incoming_post.text == '1'
    return false unless epic = selected_epic_for(user)

    epic.update(hidden:true)

    "OK, I hid #{epic.name}"
  end

  # @todo: move to EpicController
  def select_abbreviation_option user, incoming_post
    return false unless self.prev_intent_to(user) ==  Post::Intents[:coach][:showed_epic_details]
    return false unless incoming_post.text == '2'
    return false unless epic = selected_epic_for(user)

    incoming_post.update epic: epic

    "How would you like to abbreviate '#{epic.name}'?"
  end

  # @todo: move to EpicController
  def abbreviate_epic user, incoming_post
    return false unless self.prev_intent_to(user) ==  Post::Intents[:coach][:solicit_abbreviation]
    return false unless epic = selected_epic_for(user)
    return false if user.epics.where(abbreviation: incoming_post.text).exists?

    epic.update(abbreviation: incoming_post.text)

    "Ok, you can now refer to '#{epic.name}' as '#{epic.abbreviation}'"
  end

  private

    def selected_epic_for user
      last_post = user.prev_post_to self, 1
      last_post.epic if last_post
    end
end