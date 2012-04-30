class User < ActiveRecord::Base
  class << self
    def set_screen_name
      User.where("screen_name IS NULL").limit(300).each_with_index do |user,i|
        begin
          screen_name = Twitter.user(user.user_id).screen_name
          user.update_attributes!(:screen_name => screen_name)
        rescue Twitter::Error::NotFound
          user.destroy
        rescue Twitter::Error::BadRequest
          p "You can access only #{i} times"
          raise 'Twitter::Error::BadRequest'
        rescue Twitter::Error::Forbidden
          user.destroy
          next
        end
      end
    end
  end
end
