class AddUserIdToEpic < ActiveRecord::Migration
  def change
    add_column :epics, :user_id, :integer
  end
end
