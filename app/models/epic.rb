class Epic < ActiveRecord::Base
  has_many :tasks
  belongs_to :user
  belongs_to :post

  validates :user, presence: true

  scope :visible, -> { where('epics.hidden IS NULL OR epics.hidden = false') }
end