require 'monitor'

# Long-living thread pool + Monitor object
class PeopleAsyncDetailsFetcherV4
  POOL_SIZE = 20

  class MonitorArray < Array
    include MonitorMixin

    def initialize(*args)
      super(*args)
      @item_added = new_cond
    end

    alias :old_push :push
    def push(item)
      synchronize do
        old_push item
        @item_added.signal
      end
    end

    def wait_until_size_reached(cond_size)
      synchronize do
        @item_added.wait_until { self.size == cond_size }
      end
    end
  end

  class << self
    def init_pool
      return if @people_details

      @people_details = MonitorArray.new
      @queue = Queue.new
      @pool ||= POOL_SIZE.times.map do
        Thread.new do
          person_id = @queue.deq
          person_details = DataSourceGateway.get_person_details(person_id)
          @people_details.push(person_details)
        end
      end
    end

    def get_details(people_ids)
      init_pool
      @queue.push *people_ids
      @people_details.wait_until_size_reached(people_ids.size)
      @people_details
    end

    def shutdown
      @pool.each(&:exit)
    end
  end
end
