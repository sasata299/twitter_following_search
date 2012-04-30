class CreateUser < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.integer :user_id
      t.string :screen_name
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
