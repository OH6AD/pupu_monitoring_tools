import "icinga" as icinga;

fromjson
| {
    blocks: {
        value: .blocks,
    },
    blocktime: ($conf[0] + {
	raw: .mediantime,
        value: (now-.mediantime | floor),
	unit: "s",
    }),
    size: {
        value: .size_on_disk,
	unit: "B",
    },
}
| icinga::fill_icinga_state
| icinga::to_perfdata( map(.state) | max
                     ; "Median time: "+ (.blocktime.raw | strftime("%Y-%m-%d %H:%M:%S UTC"))
		     )
