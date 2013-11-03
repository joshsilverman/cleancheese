class AddCompleteByToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :complete_by, :datetime
  end
end
