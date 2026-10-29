module ApplicationHelper
  # Times are stored in UTC. Ops reads them in the shipment's destination
  # time zone, e.g. "Oct 28, 2:15 PM PDT".
  def local_time(time, zone)
    return "—" if time.nil?

    time.in_time_zone(zone).strftime("%b %-d, %-I:%M %p %Z")
  end
end
