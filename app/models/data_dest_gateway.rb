class DataDestGateway
  class << self
    def api
      @api = Faraday.new(url: 'https://api.data_dest.com') do |faraday|
        faraday.response :json, content_type: 'application/json'
      end
    end

    def send_data(contacts_data)
      response = api.post('/contacts', contacts_data.to_json)
      raise 'Alarm, alarm!' if response.status != 202
      response
    end
  end
end