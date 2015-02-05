class PeopleSync < Struct.new(:people_ids)
  def sync
    people_details = PeopleAsyncDetailsFetcher.get_details(people_ids)
    contacts = convert_people_to_contacts(people_details)
    DataDestGateway.send_data(contacts)
  end

  protected

  def convert_people_to_contacts(people_details)
    people_details.map do |person|
      {
        name: [person[:first_name], person[:first_name]].join(' '),
        home_address: person[:street_address],
        etc: 'etc.'
      }
    end
  end
end