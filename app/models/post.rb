class Post < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :tasks
  has_one :epic

  # intents
  Intents = {
      coach: {
        sending_todays_goal: 8,
        reminding_todays_goal: 9,
        
        completed_todays_goal: 0,
        showing_tasks: 10,
        created_task: 1,

        created_epic: 2,
        showed_epics: 3,
        showed_epic_details: 4,
        hide_epic: 5,
        solicit_abbreviation: 6,
        abbreviated_epic: 7
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

  def match_on_abbrev
    return false unless sender

    abbreviations = sender.epics.where('abbreviation IS NOT NULL').\
                        pluck(:abbreviation)
    abbreviations += ['do']

    regex = /^(#{abbreviations.join("|")}) (.+)/i
    text.match regex
  end
end
