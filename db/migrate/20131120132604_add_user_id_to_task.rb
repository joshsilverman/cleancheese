class AddUserIdToTask < ActiveRecord::Migration
  def up
    add_column :tasks, :user_id, :integer

    ActiveRecord::Base.record_timestamps = false
    begin
      Task.all.each { |t| t.update user_id: 2 }
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

  def down
    remove_column :tasks, :user_id, :integer
  end
end
