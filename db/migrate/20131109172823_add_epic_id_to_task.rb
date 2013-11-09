class AddEpicIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :epic_id, :integer
  end
end
