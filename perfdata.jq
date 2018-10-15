.exit,
["OK", "WARNING", "CRITICAL"][.exit] +": " + .msg + "|" +
( .data
    | to_entries
    | map( .key + "=" + ( .value
                        | [
			      .value,
			      .warn,
			      .crit,
			      if .min then .min else 0 end,
			      if .max then .max else empty end
			  ]
			| map(tostring)
		    	| join(";")
		    	))
    | join(" ")
)
