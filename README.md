# Dispatch

A trimmed-down slice of a logistics ops tool. Shipments ride on commercial flights, then a courier drives them the last mile to the consignee. Ops watches a dashboard of everything due today.

## Setup (please do this before the interview)

Requires Ruby 3.2+ and SQLite.

```sh
bin/setup --skip-server   # installs gems, creates + seeds the DB
bin/rails test            # should be green
bin/rails server          # http://localhost:3000
```

Seed data is relative to the current time, so re-run `bin/rails db:seed` right before you start.

## The domain in 30 seconds

- `Flight` – has a scheduled arrival and, once the airline feed tells us, an estimated arrival. Can be `scheduled`, `delayed`, `cancelled`, `landed`.
- `Shipment` – rides one flight; has a `deliver_by` deadline and a last-mile drive time.
- `Alert` – something ops needs to act on. Creating one pages a human.
- `POST /api/flight_updates` – the airline status feed. `FlightUpdates::Apply` does the work.
- `bin/rails "flights:delay[AS1102,45]"` / `bin/rails "flights:cancel[AS1102]"` – simulate feed updates locally (same code path as the API).

## Your ticket

> **OPS-412: Flag shipments put at risk by flight delays**
>
> Ops keeps finding out a shipment will miss its deadline when the customer calls. We already ingest airline status updates. When one comes in, figure out which shipments on that flight will now be late and tell ops.
>
> - A shipment is **at risk** when its projected delivery (flight ETA + last-mile drive) is after its `deliver_by`. A cancelled flight puts every shipment on it at risk.
> - Ops should get **one alert per at-risk shipment**, not one per feed update. The feed often repeats the same delay several times.
> - Ops wants at-risk shipments **at the top of the dashboard**: reference, consignee, flight, deliver-by and projected delivery (local time), and how late it will be.
>
> Out of scope: rebooking, notifying customers.

## How this works

- You have about ~20 minutes. Use whatever AI tools you normally use; that's the point of the exercise. Share your screen, including your AI tool.
- Think out loud. Ask us questions as you would ask a teammate.
- If you spot things in the codebase you'd do differently, mention them; don't fix them unless they block you.
- Review the changes your AI makes, and commit your work in atomic units.
- We care more about how you get there than whether you finish!
