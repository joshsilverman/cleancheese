class User < ActiveRecord::Base

  has_many :epics

  def todays_goal
    @_todays_goal ||= Task.where('complete = ? OR complete IS NULL', false).order(:rank).limit(1).first
  end

  def sms recipient, text, intent
    unless Rails.env.test?
      twilio.account.sms.messages.create(
        from: tel,
        to: recipient.tel,
        body: text
      )
    end
    Post.save_sms self, recipient, text, intent
  end

  private
    def twilio
      @_twilio ||= Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
    end
end
