# Simulate airline feed updates locally. Same code path as POST /api/flight_updates.
namespace :flights do
  desc "Delay a flight: bin/rails 'flights:delay[AS1102,45]' (minutes past schedule; 0 = back on time)"
  task :delay, [:number, :minutes] => :environment do |_, args|
    flight = Flight.find_by!(number: args.fetch(:number))
    minutes = args.fetch(:minutes).to_i
    eta = flight.scheduled_arrival_at + minutes.minutes
    FlightUpdates::Apply.call(
      "flight_number" => flight.number,
      "status" => minutes.positive? ? "delayed" : "scheduled",
      "estimated_arrival_at" => eta.iso8601
    )
    puts "#{flight.number} ETA now #{eta.in_time_zone}"
  end

  desc "Cancel a flight: bin/rails 'flights:cancel[AS1102]'"
  task :cancel, [:number] => :environment do |_, args|
    FlightUpdates::Apply.call("flight_number" => args.fetch(:number), "status" => "cancelled", "estimated_arrival_at" => nil)
    puts "#{args[:number]} cancelled"
  end
end
