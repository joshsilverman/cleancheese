class AddPostIdToEpic < ActiveRecord::Migration
  def change
    add_column :epics, :post_id, :integer
  end
end
