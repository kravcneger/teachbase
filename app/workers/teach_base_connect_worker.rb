class TeachBaseConnectWorker
  include Sidekiq::Worker

  def perform
    TeachbaseClient.new.get('/')
 
  rescue RestClient::Exceptions::Timeout => err
    Rails.cache.fetch('last_server_activity') do
      Time.zone.now
    end
    TeachBaseConnectWorker.perform_in(2.minutes)
    Rails.cache.write('server_not_available', 'true')
  else
    Rails.cache.delete('last_server_activity')
    Rails.cache.delete('server_not_available')
  end

end
