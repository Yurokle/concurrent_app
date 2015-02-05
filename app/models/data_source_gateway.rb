class DataSourceGateway
  class << self
    def api
      @api = Faraday.new(url: 'https://api.data_source.com') do |faraday|
        faraday.response :json, content_type: 'application/json'
      end
    end

    def get_page(page_num)
      api.get("/people/#{page_num}")
    end

    def get_person_details(person_id)
      api.get("/person/details/#{person_id}")
    end
  end
end