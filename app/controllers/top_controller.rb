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
            unless user = User.find_by_user_id(user_id)
              begin
                obj = Twitter.user(user_id)
                user = User.create!(
                  :user_id => user_id,
                  :screen_name => obj.screen_name,
                  :profile => obj.description.strip,
                  :url => obj.url
                )
              rescue
                next
              end
            end

            user_info[user.screen_name] += 1 if user.screen_name
          end
        end
      end

      output(user_info.select{|name, count| count > 1})
    end
  end

  private

  def output(user_info)
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    user_info.sort{|a,b| b[1] <=> a[1]}[0..99].each_with_index do |user,i|
      user[2] = "https://twitter.com/#!/#{user[0]}"
      sheet.row(i).concat user
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
