class IndexController < ApplicationController
  def index
    raise RestClient::Exceptions::Timeout unless last_server_activity.nil?

    @courses = TeachbaseClient.new.get('/endpoint/v1/course_sessions').body
  rescue RestClient::ImATeapot => err
    flash[:error] = "В данный момент Teachbase недоступен. Загружена копия от #{last_server_activity}"
  rescue RestClient::Exceptions::Timeout => err

    TeachBaseConnectWorker.perform
    flash[:error] = "Teachbase лежит уже #{server_downtime} часов"
  else    
    Rails.cache.delete('last_server_activity')
    Rails.cache.write('courses', @courses)
  ensure
    @courses ||= Rails.cache.fetch('courses') || []
    @courses = JSON.parse(@courses)
  end


  private 

  def last_server_activity
    Rails.cache.fetch('last_server_activity')
  end

  def server_downtime
    ((Time.zone.now - last_server_activity) / 3600).round
  end

end