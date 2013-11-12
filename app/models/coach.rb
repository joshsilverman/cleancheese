class Coach < User
  include FuzzyTime
  include Commands

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

  def respond user, incoming_post
    response, intent = interpret(user, incoming_post)

    if response
      sms(user, response, intent)
    else
      false
    end
  end

  def interpret user, incoming_post
    if response = complete_todays_goal(user, incoming_post)
      intent = Post::Intents[:coach][:completed_todays_goal]
    elsif response = create_task(user, incoming_post)
      intent = Post::Intents[:coach][:created_task]
    elsif response = create_epic(user, incoming_post)
      intent = Post::Intents[:coach][:created_epic]
    elsif response = show_epics(user, incoming_post)
      intent = Post::Intents[:coach][:showed_epics]
    elsif response = show_epic_details(user, incoming_post)
      intent = Post::Intents[:coach][:showed_epic_details]
    elsif response = hide_epic(user, incoming_post)
      intent = Post::Intents[:coach][:hide_epic]
    else
      intent = nil
      response = nil
    end

    return response, intent
  end

  # @todo make private
  def interpret_msg_with_complete_by_str msg_with_complete_by_str

    msg = strip_complete_by_str msg_with_complete_by_str
    date = convert_fuzzy_datetime_str_to_datetime msg_with_complete_by_str

    return msg, date
  end

end