module Commands

  def complete_todays_goal user, incoming_post
    return false unless incoming_post.text.downcase.include? "done"
    if todays_goal and todays_goal.update(complete: true, completed_at: Time.now)
      "Nice job"
    else
      "Looks like you need to add more goals."
    end
  end

  def create_task user, incoming_post
    new_task_name_match = incoming_post.text.match(/^do (.+)/i)
    return false unless new_task_name_match

    task_name_with_complete_by_str = new_task_name_match[1]
    task_name, complete_by = 
      interpret_msg_with_complete_by_str(task_name_with_complete_by_str)

    incoming_post.tasks.create(name: task_name, complete_by: complete_by)

    "I just added a new task: #{task_name}"
  end

  def create_epic user, incoming_post
    new_epic_name_match = incoming_post.text.match(/^new epic (.+)/i)
    return false unless new_epic_name_match

    new_epic_name = new_epic_name_match[1]

    Epic.create(name: new_epic_name, user_id: user.id)

    "I created a new epic: #{new_epic_name}"
  end

  def show_epics user, incoming_post
    match = incoming_post.text.match(/^show epics/i)
    return false unless match

    response = "Epics:\n"
    
    user.epics.visible.each_with_index do |epic, i|
      response += " (#{i+1}) #{epic.name}"
    end
    response += "\n\nReply '1','2' ... for options"

    response
  end

  def show_epic_details user, incoming_post
    last_coach_post = Post.where(sender: self, recipient: user)\
                                .order(created_at: :desc).first
    return false unless last_coach_post
    return false unless last_coach_post.intent == Post::Intents[:coach][:showed_epics]

    epic_index = incoming_post.text.to_i - 1
    return false unless epic_index >= 0

    epic = user.epics.offset(epic_index).first
    return false unless epic
    incoming_post.update(epic: epic)
    
    actions = "\n\nReply '1' to hide"

    "#{epic.name} Epic Options:" + actions
  end

  def hide_epic user, incoming_post
    last_coach_post = Post.where(sender: self, recipient: user)\
                                .order(created_at: :desc).first
    return false unless last_coach_post
    return false unless last_coach_post.intent == Post::Intents[:coach][:showed_epic_details]
    return false unless incoming_post.text == '1'
    
    last_user_post = Post.where(sender: user, recipient: self)\
                                .order(created_at: :desc)[1]

    return false unless last_user_post and last_user_post.epic
    epic = last_user_post.epic
    
    epic.update(hidden:true)

    "OK, I hid #{epic.name}"
  end
end