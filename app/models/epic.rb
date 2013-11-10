class Epic < ActiveRecord::Base
  has_many :tasks
  belongs_to :user

  validates :user, presence: true
end
