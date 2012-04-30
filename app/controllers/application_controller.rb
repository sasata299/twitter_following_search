class ApplicationController < ActionController::Base
  protect_from_forgery

  def param_check
    unless params[:token] && params[:token] == ENV['AUTHENTICATION_TOKEN']
      raise 'Unauthorized user'
    end
  end
end
