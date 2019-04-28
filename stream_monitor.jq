import "icinga" as icinga;

split("\n") |
map(match("^(.*):[[:space:]]*(.*)") |
    .captures |
    map(.string) |
    { key: (.[0] | sub("[[:space:]]+";" ")),
      value: { value: (.[1] | try tonumber catch empty) }
    }
   ) |
from_entries * { "RMS amplitude":  { warn: 0.1, crit: 0.05 }} |
icinga::fill_icinga_state |
icinga::to_perfdata(map(.state) | max; "RMS amplitude: " + (.["RMS amplitude"].value | tostring))
