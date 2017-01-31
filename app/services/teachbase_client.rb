require 'rest-client'
require 'json'

class TeachbaseClient
  
  TEACHBASE_HOST = 'http://s1.teachbase.ru'

  def initialize(client_id = nil, client_secret = nil)
    @client_id = client_id || Rails.application.config.teachbase_client_id
    @client_secret = client_secret || Rails.application.config.teachbase_client_secret
  end

  def get(request, headers={}, &block)
    headers.merge!({ 'Authorization' => "Bearer #{get_token}" })
    RestClient.get(TEACHBASE_HOST + request, headers)
  end

  def get_token
    response = RestClient.post TEACHBASE_HOST + '/oauth/token', {
      grant_type: 'client_credentials',
      client_id: @client_id,
      client_secret: @client_secret
    }
    JSON.parse(response)["access_token"]
  end


end