class Post < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  def self.save_sms sender, recipient, text
    Post.create sender: sender, recipient: recipient, text: text
  end
end
