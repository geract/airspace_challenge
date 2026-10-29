# Seed data is relative to now so the dashboard always has something "due today".
Alert.delete_all
Shipment.delete_all
Flight.delete_all

now = Time.current.change(sec: 0)

as1102 = Flight.create!(number: "AS1102", origin: "SEA", destination: "LAX", scheduled_arrival_at: now + 2.hours)
ua2290 = Flight.create!(number: "UA2290", origin: "ORD", destination: "SFO", scheduled_arrival_at: now + 3.hours)
dl4410 = Flight.create!(number: "DL4410", origin: "ATL", destination: "SAN", scheduled_arrival_at: now + 90.minutes)

la = "America/Los_Angeles"
[
  { reference: "AIR-1001", consignee: "Cedars Reference Lab", flight: as1102, deliver_by: now + 3.hours,     last_mile_minutes: 40, status: "in_transit" },
  { reference: "AIR-1002", consignee: "Westside Dental",      flight: as1102, deliver_by: now + 5.hours,     last_mile_minutes: 35, status: "in_transit" },
  { reference: "AIR-1003", consignee: "Mission Bay Biotech",  flight: ua2290, deliver_by: now + 4.hours,     last_mile_minutes: 50, status: "booked" },
  { reference: "AIR-1004", consignee: "Presidio Imaging",     flight: ua2290, deliver_by: now + 3.5.hours,   last_mile_minutes: 30, status: "cancelled" },
  { reference: "AIR-1005", consignee: "Scripps Cardiology",   flight: dl4410, deliver_by: now + 150.minutes, last_mile_minutes: 30, status: "in_transit" },
  { reference: "AIR-1006", consignee: "La Jolla Genomics",    flight: dl4410, deliver_by: now + 6.hours,     last_mile_minutes: 25, status: "booked" }
].each { |attrs| Shipment.create!(attrs.merge(destination_time_zone: la)) }

puts "Seeded #{Flight.count} flights, #{Shipment.count} shipments."
