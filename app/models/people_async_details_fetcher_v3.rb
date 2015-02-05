require 'monitor'

# Long-living thread pool + Condition Variable
class PeopleAsyncDetailsFetcherV3
  POOL_SIZE = 20

  class << self
    def init_pool
      return if @people_details
      @people_details = []
      @person_added = ConditionVariable.new
      @mutex = Mutex.new
      @queue = Queue.new

      @pool ||= POOL_SIZE.times.map do
        Thread.new do
          person_id = @queue.deq
          person_details = DataSourceGateway.get_person_details(person_id)
          @mutex.synchronize do
            @people_details.push person_details
            @person_added.signal
          end
        end
      end
    end

    def get_details(people_ids)
      init_pool
      @people_ids.each{ |person_id| @queue.push(person_id) }

      @mutex.synchronize do
        until @people_ids.size == @people_details.size
          @person_added.wait(@mutex)
        end
      end

      @people_details
    end

    def shutdown
      @pool.each(&:exit)
    end
  end
end

# class PeopleAsyncDetailsFetcherV2
#   def self.get_details(people_ids)
#     threads = people_ids.map do |person_id|
#       Thread.new(person_id) do |person_id|
#         DataSourceGateway.get_person_details(person_id)
#       end
#     end
#     threads.map(&:value)
#   end
# end

