class Coach < User

  # coach
  def respond user, incoming_post
    complete_todays_goal user
  end

  # coach
  def complete_todays_goal user
    if todays_goal and todays_goal.update(complete: true)
      msg = "Nice job #{user.name}"
    else
      msg = "Looks like you need to add more goals."
    end
    sms(user, msg)
  end

  # coach
  def send_todays_goal user
    top_ranked_task = todays_goal
    msg = "Today's goal: #{top_ranked_task.name}"
    sms(user, msg)
  end

  # coach
  def send_reminder user
    top_ranked_task = todays_goal
    msg = "Don't forget your goal for today: #{top_ranked_task.name}"
    sms(user, msg)
  end

end