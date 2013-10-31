class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :text
      t.integer :sender_id
      t.integer :recipient_id

      t.timestamps
    end
  end
end
