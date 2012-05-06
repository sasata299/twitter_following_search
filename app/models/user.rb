class User < ActiveRecord::Base
  class << self
    def set_screen_name
      User.where("profile IS NULL").limit(300).each_with_index do |user,i|
        begin
          obj = Twitter.user(user.user_id)
          user.update_attributes!(:profile => obj.description.strip, :url => obj.url)
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
