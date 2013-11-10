class AddIntentToPost < ActiveRecord::Migration
  def change
    add_column :posts, :intent, :integer
  end
end
