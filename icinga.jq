def to_perfdata(exit; msg):
    exit,
    ["OK", "WARNING", "CRITICAL"][exit] +": " + msg + "|" +
    ( to_entries | map( .key + "=" + (
	.value | [
	    .value,
	    .warn,
	    .crit,
	    if .min then .min else 0 end,
	    if .max then .max else empty end
	] | map(tostring) | join(";")
    )) | join(" ")
    );

# Inject success state
def fill_icinga_state:
    map_values(.+{state:(if .crit > .warn then
	if .value > .crit then
	    2
	else
	    if .value > .warn then
		1
	    else
		0
	    end
	end
    else
	if .value < .crit then
	    2
	else
	    if .value < .warn then
		1
	    else
		0
	    end
	end
    end)});
