{ msg: ( "connections: " + (del(.ratio) | map(.value) | add | tostring)
       + ", ratio: " + (.ratio.value*100+0.5 | floor/100 | tostring)
       )
, data: .
, exit: map(.state) | max
}
