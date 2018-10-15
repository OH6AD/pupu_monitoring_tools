# Input lines to array and group identical elements
lines | group_by(.)
# Take mandatory elements and combine them with element counts
| ( $conf[0].items | map({key:., value:0})) + map({key:.[0], value: length})
| from_entries
# Fill in limits to the object
| map_values($conf[0].item_limits + {value:.})
    + { ratio: ($conf[0].ratio_limits + {max: 1, value: (map(.) | min / add * length)})}
# Check limits
| fill_icinga_state
# Add exit value and message based on checked limits and produce perfdata
| to_perfdata(map(.state) | max;
              "connections: " + (del(.ratio) | map(.value) | add | tostring) +
	      ", ratio: " + (.ratio.value*100+0.5 | floor/100 | tostring))
