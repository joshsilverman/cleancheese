class AddHiddenToEpic < ActiveRecord::Migration
  def change
    add_column :epics, :hidden, :boolean
  end
end
