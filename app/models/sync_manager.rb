class SyncManager
  def sync
    puts 'Sync started...'
    people_pages = PeoplePagesGateway.new

    while page = people_pages.get_next_page
      at_least_n_seconds_block(10) do
        people_ids = page['people'].map{ |person| person['id'] }
        PeopleSync.new(people_ids).sync
      end
    end
    shutdown

    puts 'Sync completed.'
  end

  def shutdown
    PeopleAsyncDetailsFetcher.shutdown
  end
end