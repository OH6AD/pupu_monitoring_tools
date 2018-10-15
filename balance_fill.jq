lines | group_by(.)
    | ( $conf[0].items | map({key:., value:0})) + map({key:.[0], value: length})
    | from_entries
    | map_values($conf[0].item_limits + {value:.})
    + { ratio: ($conf[0].ratio_limits + {max: 1, value: (map(.) | min / add * length)})}
