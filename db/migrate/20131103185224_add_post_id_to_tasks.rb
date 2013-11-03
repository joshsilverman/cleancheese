class AddPostIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :post_id, :integer
  end
end
