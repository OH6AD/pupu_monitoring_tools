import "utils" as utils;
import "icinga" as icinga;

# Assume output from ̀chrony -c sources` and parse if it has been too
# long without a sync or the clock is in falseticker or variating
# state.
utils::lines
| map( split(",")
     | { mode: {"^": "server"
               ,"#": "peer"
	       ,"=": "local"}[.[0]]
       , clock: {"*": "synchronized"
                ,"+": "acceptable"
	        ,"?": "lost"
	        ,"x": "falseticker"
	        ,"~": "variating"
	        }[.[1]]
       , name: .[2]
       , value: (.[6] | tonumber)
       , unit: "s"
       , is_sane: (.[1] | inside("*+?"))
       }
     | { key: .name
       , value: ($conf[0] + . + { text:(.name + " " + .mode + " " + .clock + " " + (.value | tostring) + " seconds ago")})
       }
     )
| from_entries
# Check limits
| icinga::fill_icinga_state
# Add exit value and message based on checked limits and produce perfdata
| icinga::to_perfdata( map(.state, if .is_sane then 0 else 2 end) | max
  		     ; map(.text) | join(";")
		     )
