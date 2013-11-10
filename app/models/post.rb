class Post < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :tasks

  # intents
  Intents = {
      coach: {
        completed_todays_goal: 0,
        created_task: 1,
        created_epic: 2,
        showed_epics: 3,
        showed_epic_details: 4
    },
      user: {
      }
    }

  def self.save_sms sender, recipient, text, intent
    Post.create sender: sender, 
                recipient: recipient, 
                text: text, 
                intent:intent
  end
end
