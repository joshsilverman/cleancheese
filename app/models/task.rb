class Task < ActiveRecord::Base
  include RankedModel
  ranks :rank

  def self.active
    show_conditions = "updated_at > ? 
                       OR complete <> true
                       OR complete IS NULL"
    where(show_conditions, 7.days.ago)
  end
end