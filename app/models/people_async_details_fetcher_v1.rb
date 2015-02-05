# Short living threads version with mutex
class PeopleAsyncDetailsFetcherV1
  def self.get_details(people_ids)
    people_details = []
    mutex = Mutex.new

    threads = people_ids.map do |person_id|
      Thread.new(person_id) do |person_id|
        person_details = DataSourceGateway.get_person_details(person_id)
        mutex.synchronize do
          people_details.push(person_details)
        end
      end
    end
    threads.map(&:join)

    people_details
  end
end
