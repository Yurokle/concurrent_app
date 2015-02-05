class PeoplePagesGateway
  class Page < Struct.new(:response)
    def [](key)
      response.body[key]
    end

    def last_page?
      !self['has_more']
    end
  end

  def initialize
    @pages_fetcher = Fiber.new do
      page_num = 0
      begin
        page_num += 1
        page = Page.new(DataSourceGateway.get_page(page_num))
        Fiber.yield(page)
      end until(page.last_page?)
    end
  end

  def get_next_page
    @pages_fetcher.resume
  end
end