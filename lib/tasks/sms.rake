namespace :sms do
  task goal: :environment do
    coach = Coach.where(tel: '+12077473228', name: 'Coach').first_or_create
    user = User.where(tel: '+12079393305', name: 'Josh').first_or_create
    coach.send_todays_goal user
  end

  # task quote: :environment do
  # end

  task reminder: :environment do
    coach = Coach.where(tel: '+12077473228', name: 'Coach').first_or_create
    user = User.where(tel: '+12079393305', name: 'Josh').first_or_create
    coach.send_reminder user
  end
end