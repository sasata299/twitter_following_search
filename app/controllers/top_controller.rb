class TopController < ApplicationController
  before_filter :param_check

  def index
    if request.post?
      if params[:urls].blank?
        @error = 'Please specify urls'
        render :index
        return
      end

      user_info = Hash.new{|h,k| h[k] = 0}

      params[:urls].split(/\r?\n/).each do |url|
        if url =~ %r[https://twitter\.com/#!/(.+)]
          Twitter.friend_ids($1).ids.each do |user_id|
            user_info[user_id] += 1
          end
        end
      end

      output(user_info.select{|user_id, count| count > 1})
    end
  end

  private

  def output(user_info)
    #Spreadsheet.client_encoding = 'cp932'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    user_info.sort{|a,b| b[1] <=> a[1]}[0..99].each_with_index do |u,i|
      unless user = User.find_by_user_id(u[0])
        begin
          obj = Twitter.user(u[0])
          user = User.create!(
            :user_id => u[0],
            :screen_name => obj.screen_name,
            :profile => obj.description.strip,
            :url => obj.url
          )
        rescue
          next
        end
      end

      #profile = NKF.nkf('-s -m0', user.profile)
      sheet.row(i).concat [user.screen_name, u[1], user.profile, user.url]
    end

    tmpfile = Tempfile.new ['result', '.xls']
    book.write tmpfile.path

    send_file(
      tmpfile.path,
      :disposition => 'attachment',
      :type => 'application/octet-stream',
      :filename => 'result.xls'
    )
  end
end
