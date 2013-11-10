class UsersController < ApplicationController
  respond_to :json
  protect_from_forgery :except => :receive_sms 

  def receive_sms
    text = params["Body"]
    coach = Coach.find_by(tel: params["To"])
    user = User.find_by(tel: params["From"])

    incoming_message = Post.save_sms user, coach, text, nil

    if user and coach.respond user, incoming_message
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, nothing: true
    end
  end
end