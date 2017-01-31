class IndexController < ApplicationController
  def index
    raise RestClient::Exceptions::Timeout unless available_server?

    @courses = TeachbaseClient.new.get('/endpoint/v1/course_sessions').body
  rescue RestClient::ImATeapot => err
    flash[:error] = "В данный момент Teachbase недоступен. Загружена копия от #{last_server_activity}"
  rescue RestClient::Exceptions::Timeout => err

    TeachBaseConnectWorker.perform
    flash[:error] = "Teachbase лежит уже #{server_downtime} часов"
  else    
    Rails.cache.delete('server_not_available')
    Rails.cache.write('courses', @courses)
    Rails.cache.write('last_server_activity', Time.zone.now)
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

  def available_server?
    Rails.cache.fetch('server_not_available').nil?
  end

end