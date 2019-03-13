# Usage:
# journalctl -u mautrix-telegram --reverse -o json |
# icingafilter telegram_last_message telegram_limits.json "-r --unbuffered"

import "icinga" as icinga;

# Check whih is the last message from Telegram
if (.MESSAGE | test("Handled Telegram message"))
then now-(.__REALTIME_TIMESTAMP | tonumber / 1e6) | floor
else empty
end
| { telegram: ($conf[0] + { value: ., unit: "s" }) }
| icinga::fill_icinga_state
| icinga::to_perfdata(.telegram.state; "Last Telegram message " + (.telegram.value | tostring) + "s ago")

