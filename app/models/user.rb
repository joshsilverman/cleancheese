class User < ActiveRecord::Base

  has_many :epics
  has_many :tasks

  def prev_post_to user, i = 0
    Post.where(sender: self, recipient: user)\
        .order(created_at: :desc).offset(i).first
  end

  def prev_intent_to user, i = 0
    prev_post = prev_post_to user, i
    prev_post.intent if prev_post
  end

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
