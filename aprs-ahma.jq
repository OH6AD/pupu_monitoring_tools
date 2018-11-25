import "icinga" as icinga;
import "utils" as utils;

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

( .MESSAGE | match("# (aprsc .*)") | .captures[0].string |
{
    state: 0,
    msg: .,
    value: 0,
} | icinga::to_service_check_result_simple("jonne"; "aprx")),
(
{raw: .} + (
    .MESSAGE |
    match(" ([0-9]+) ([0-9.]+)C ([0-9.]+)W ([0-9.]+)V ([0-9]+)%\\|(..)(..)(..)(..)(..)(..)(..)\\|$") |
    (.captures) |
    {
	bits: .[11].string | base91dec | (convert(2) + [0,0,0,0,0,0,0,0])[:8] | reverse | map(.==1),
	data: map(.string)
    }
) | {
     ts:            (.raw.__REALTIME_TIMESTAMP | tonumber / 1e6),
     temp_box:      .data[1] | tonumber,
     power:         .data[2] | tonumber,
     voltage:       .data[3] | tonumber,
     battery:       .data[4] | tonumber,
     seq:           .data[5] | base91dec,
     temp_out:      (if .bits[0] then .data[6] | base91dec | eqn else null end), 
     temp_in:       (if .bits[1] then .data[7] | base91dec | eqn else null end),
     humi_in:       (if .bits[1] then .data[8] | base91dec else null end),
     temp_basement: (if .bits[2] then .data[9] | base91dec | eqn else null end),
     humi_basement: (if .bits[2] then .data[10] | base91dec else null end),
     in_bat:        (if .bits[1] then .bits[3] else null end),
     basement_bat:  (if .bits[2] then .bits[4] else null end),
     internet:      .bits[5],
     grid:          .bits[6],
     pk:            .bits[7],
     free_blocks:   .data[0] | tonumber
} | ([
    (.ts | todateiso8601),
    .temp_box,
    .power,
    .voltage,
    .battery,
    .seq,
    .temp_out,
    .temp_in,
    .humi_in,
    .temp_basement,
    .humi_basement,
    .in_bat,
    .basement_bat,
    .internet,
    .grid,
    .pk,
    .free_blocks
] | @csv),
({
    value: .temp_in,
    msg: (.temp_in | utils::round(1) + "°C"),
    crit: 5,
    warn: 10
} | icinga::service_simple("ahma";"temp_in")),
({
    value: (479948800-.free_blocks*4096),
    msg: (.free_blocks*0.004096 + 0.5 | floor | tostring + "MB free"),
    unit: "B",
    max: 479948800,
    crit: (0.95*479948800),
    warn: (0.90*479948800)
} | icinga::service_simple("ahma";"disk")),
({
    value: .battery,
    unit: "%",
    max: 100,
    crit: 50,
    warn: 75
} | icinga::service_simple("ahma";"battery")),
({
    state: (if .grid then 0 else 1 end),
    msg: (if .grid then "Grid powered" else "Battery powered" end),
    value: (if .grid then 1 else 0 end),
} | icinga::to_service_check_result_simple("ahma"; "grid"))
)
