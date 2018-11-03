def base91dec:
    explode | map(.-33) | (.[0] * 91 + .[1]);

def eqn:
    (./10-100);

# Simplified from https://rosettacode.org/wiki/Non-decimal_radices/Convert#jq
def convert(base):
  def stream:
    recurse(if . > 0 then ./base|floor else empty end) | . % base ;
  if . == 0 then [0]
  else [stream] | reverse | .[1:]
  end;

{raw: .} + (
    .MESSAGE |
    match(" ([0-9.]+)C ([0-9.]+)W ([0-9.]+)V ([0-9]+)%\\|(..)(..)(..)(..)(..)(..)(..)\\|$") |
    (.captures) |
    {
	bits: .[10].string | base91dec | (convert(2) + [0,0,0,0,0,0,0,0])[:8] | reverse | map(.==1),
	data: map(.string)
    }
) | [
    (.raw.__REALTIME_TIMESTAMP | tonumber / 1e6 | todateiso8601 ),  # ts
    (.data[0] | tonumber),                                       # temp_box
    (.data[1] | tonumber),                                       # power
    (.data[2] | tonumber),                                       # voltage
    (.data[3] | tonumber),                                       # battery
    (.data[4] | base91dec),                                      # seq
    (if .bits[0] then .data[5] | base91dec | eqn else null end), # temp_out
    (if .bits[1] then .data[6] | base91dec | eqn else null end), # temp_in
    (if .bits[1] then .data[7] | base91dec else null end),       # humi_in
    (if .bits[2] then .data[8] | base91dec | eqn else null end), # temp_basement
    (if .bits[2] then .data[9] | base91dec else null end),       # humi_basement
    (if .bits[1] then .bits[3] else null end),                   # in_bat
    (if .bits[2] then .bits[4] else null end),                   # basement_bat
    .bits[5],                                                    # internet
    .bits[6],                                                    # on_line
    .bits[7]                                                     # pk
] | @csv
