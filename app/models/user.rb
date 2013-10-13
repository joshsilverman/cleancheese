class User < ActiveRecord::Base

  def send_todays_goal user
    top_ranked_task = Task.order(:rank).limit(1).first.name
    msg = "Today's goal: #{top_ranked_task}"
    sms(user, msg)
  end

  def send_reminder user
    top_ranked_task = Task.order(:rank).limit(1).first.name
    msg = "Don't forget your goal for today: #{top_ranked_task}"
    sms(user, msg)
  end

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
