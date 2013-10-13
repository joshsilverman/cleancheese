class User < ActiveRecord::Base

  # user
  def todays_goal
    @_todays_goal ||= Task.where('complete = ? OR complete IS NULL', false).order(:rank).limit(1).first
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

  # base
  def sms user, msg
    twilio.account.sms.messages.create(
      from: tel,
      to: user.tel,
      body: msg
    )
  end

  private
    def twilio
      @_twilio ||= Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
    end
end
