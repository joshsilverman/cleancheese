class AddAbbreviationToEpic < ActiveRecord::Migration
  def change
    add_column :epics, :abbreviation, :string
  end
end
