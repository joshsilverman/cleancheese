class UsersController < ApplicationController
  respond_to :json
  protect_from_forgery :except => :receive_sms 

  def receive_sms
    msg = params["Body"]
    coach = User.find_by(tel: params["To"])
    user = User.find_by(tel: params["From"])
    if user and coach.complete_todays_goal user
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, nothing: true
    end
  end
end