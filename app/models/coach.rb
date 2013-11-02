class Coach < User

  def respond user, incoming_post
    msg = interpret incoming_post

    if msg
      sms(user, msg)
    else
      false
    end
  end

  def interpret incoming_post
    if msg = complete_todays_goal(incoming_post)
    elsif msg = create_task_for_user(incoming_post)
    else
      msg = nil
    end

    msg
  end

  def complete_todays_goal incoming_post
    return false unless incoming_post.text.include? "done"

    if todays_goal and todays_goal.update(complete: true)
      "Nice job"
    else
      "Looks like you need to add more goals."
    end
  end

  def create_task_for_user incoming_post
    new_task_name_match = incoming_post.text.match(/^do (.+)/)
    return false unless new_task_name_match
    new_task_name = new_task_name_match[1]

    Task.create name: new_task_name

    "I just added a new task: #{new_task_name}"
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
end