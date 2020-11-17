import "icinga" as icinga;
import "utils" as utils;

def base91dec:
    explode | reduce .[] as $x (0; .*91+$x-33);

def eqn:
    (./10-100);

def eqncent:
    (./100);

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
    match(" (....)(....)(..)(..)(..)(..)\\|(..)(..)(..)(..)(..)(..)(..)\\|") |
    (.captures) |
    {
	bits: .[12].string | base91dec | ([0,0,0,0,0,0,0,0] + convert(2) | reverse)[:8] | map(.==1),
	data: map(.string)
    }
) | {
     ts:            (.raw.__REALTIME_TIMESTAMP | tonumber / 1e6),
     temp_box:      .data[2] | base91dec | eqn,
     voltage:       .data[3] | base91dec | eqncent,
     current:       .data[4] | base91dec | eqncent,
     humidity_out:  (if .bits[0] then .data[5] | base91dec else null end),
     seq:           .data[6] | base91dec,
     temp_out:      (if .bits[0] then .data[7] | base91dec | eqn else null end), 
     temp_in:       (if .bits[1] then .data[8] | base91dec | eqn else null end),
     humi_in:       (if .bits[1] then .data[9] | base91dec else null end),
     temp_basement: (if .bits[2] then .data[10] | base91dec | eqn else null end),
     humi_basement: (if .bits[2] then .data[11] | base91dec else null end),
     in_bat:        (if .bits[1] then .bits[3] else null end),
     basement_bat:  (if .bits[2] then .bits[4] else null end),
     internet:      .bits[5],
     out_bat:       .bits[6],
     pk:            .bits[7],
     free_blocks:   .data[1] | base91dec,
     uptime:        .data[0] | base91dec,
     grid:          ((.data[3] | base91dec | eqncent) > 14.5) # Inferred from voltage
} | ([
    (.ts | todateiso8601),
    .temp_box,
    .voltage,
    .humidity_out,
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
    .free_blocks,
    .uptime,
    .out_bat,
    .current
] | @csv),
({
    state: 0,
    msg: "Connected",
    value: 1
} | icinga::to_service_check_result_simple("ahma"; "aprs")),
(if .temp_in == null then empty else {
    value: .temp_in,
    msg: (.temp_in | utils::round(1) + "°C"),
    crit: 5,
    warn: 10
} | icinga::service_simple("ahma";"temp_in") end),
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
    crit: 20,
    warn: 45
} | icinga::service_simple("ahma";"battery")),
({
    state: (if .grid then 0 else 1 end),
    msg: (if .grid then "Grid powered" else "Battery powered" end),
    value: (if .grid then 1 else 0 end),
} | icinga::to_service_check_result_simple("ahma"; "grid"))
)
