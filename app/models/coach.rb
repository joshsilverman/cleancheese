class Coach < User
  include FuzzyTime

  def respond user, incoming_post
    msg = interpret(user, incoming_post)

    if msg
      sms(user, msg)
    else
      false
    end
  end

  def interpret user, incoming_post
    if response = complete_todays_goal(user, incoming_post)
    elsif response = create_task_for_user(user, incoming_post)
    elsif response = create_epic_for_user(user, incoming_post)
    elsif response = show_epics_for_user(user, incoming_post)
    else
      response = nil
    end

    response
  end

  def complete_todays_goal user, incoming_post
    return false unless incoming_post.text.downcase.include? "done"
    if todays_goal and todays_goal.update(complete: true, completed_at: Time.now)
      "Nice job"
    else
      "Looks like you need to add more goals."
    end
  end

  def create_task_for_user user, incoming_post
    new_task_name_match = incoming_post.text.match(/^do (.+)/i)
    return false unless new_task_name_match

    task_name_with_complete_by_str = new_task_name_match[1]
    task_name, complete_by = 
      interpret_msg_with_complete_by_str(task_name_with_complete_by_str)

    incoming_post.tasks.create(name: task_name, complete_by: complete_by)

    "I just added a new task: #{task_name}"
  end

  def create_epic_for_user user, incoming_post
    new_epic_name_match = incoming_post.text.match(/^new epic (.+)/i)
    return false unless new_epic_name_match

    new_epic_name = new_epic_name_match[1]

    Epic.create(name: new_epic_name, user_id: user.id)

    "I created a new epic: #{new_epic_name}"
  end

  def show_epics_for_user user, incoming_post
    match = incoming_post.text.match(/^show epics/i)
    return false unless match

    epics_names = user.epics.map &:name

    (["Epics:"] + epics_names).join("\n-")
  end

  def send_todays_goal user
    top_ranked_task = todays_goal
    msg = "Today's goal: #{top_ranked_task.name}"
    sms(user, msg)
  end

  def send_reminder user
    top_ranked_task = todays_goal
    msg = "Don't forget your goal for today: #{top_ranked_task.name}"
    sms(user, msg)
  end

  # @todo make private
  def interpret_msg_with_complete_by_str msg_with_complete_by_str

    msg = strip_complete_by_str msg_with_complete_by_str
    date = convert_fuzzy_datetime_str_to_datetime msg_with_complete_by_str

    return msg, date
  end

end