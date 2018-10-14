.exit,
["OK", "WARNING", "CRITICAL"][.exit] +": " + .msg + "|" +
( .data
    | to_entries
    | map( .key + "=" + ( .value
                        | [
			      .value,
			      .warn,
			      .crit,
			      if .max then .max else empty end
			  ]
			| map(tostring)
		    	| join(";")
		    	))
    | join(" ")
)
