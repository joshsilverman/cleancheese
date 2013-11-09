class CreateEpics < ActiveRecord::Migration
  def change
    create_table :epics do |t|
      t.string :name

      t.timestamps
    end
  end
end
