# Usage:
# journalctl -u mautrix-telegram --reverse -o json |
# icingafilter telegram_last_message telegram_limits.json "-r --unbuffered"

import "icinga" as icinga;

# Temporary hack: journalctl encodes as an array if it contains non-UTF8 chars.
# Just imploding it if there is a message array. Breaks UTF-8 chars.
.MESSAGE = (.MESSAGE | if type == "array" then implode else . end)
# Check whih is the last message from Telegram
| if (.MESSAGE | test("Handled Telegram message";"i"))
then now-(.__REALTIME_TIMESTAMP | tonumber / 1e6) | floor
else empty
end
| { telegram: ($conf[0] + { value: ., unit: "s" }) }
| icinga::fill_icinga_state
| icinga::to_perfdata(.telegram.state; "Last Telegram message " + (.telegram.value | tostring) + "s ago")

