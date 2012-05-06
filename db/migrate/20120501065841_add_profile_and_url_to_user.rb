class AddProfileAndUrlToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :profile, :string, :after => :screen_name
    add_column :users, :url, :string, :after => :profile
  end

  def self.down
    remove_column :users, :profile
    remove_column :users, :url
  end
end
