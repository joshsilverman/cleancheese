class Task < ActiveRecord::Base

  belongs_to :post
  belongs_to :epic
  belongs_to :user

  include RankedModel
  ranks :rank, scope: :active

  def self.active
    show_conditions = "tasks.updated_at > ? 
                       OR complete <> true
                       OR complete IS NULL"
    where(show_conditions, 7.days.ago)
  end
end