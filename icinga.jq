def to_perfdata_line(exit; msg):
    ["OK", "WARNING", "CRITICAL"][exit] +": " + msg + "|" +
    ( to_entries | map( .key + "=" + (
	.value | [(.value | tostring) + .unit] +
	    if .warn then [
		.warn,
		.crit,
		if .min then .min else 0 end,
		if .max then .max else empty end
	    ] else [] end
	| map(tostring) | join(";")
    )) | join(" ")
    );

def to_perfdata(exit; msg):
    to_perfdata_line(exit; msg) | exit, .;

def to_service_check_result(host; service; exit; msg):
    [
	"PROCESS_SERVICE_CHECK_RESULT",
	host,
	service,
	(exit | tostring),
	to_perfdata_line(exit; msg)
    ] | join(";");

def to_service_check_result_simple(host; service):
    . as $me |
    [{ key: service, value: . }] | from_entries | to_service_check_result(host; service; $me.state; ($me.value|tostring) + $me.unit);

# Inject success state
def fill_icinga_state_simple:
    .state = (if .crit > .warn then
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
    end);

def fill_icinga_state:
    map_values(fill_icinga_state_simple);

def service_simple(host; service):
    fill_icinga_state_simple | to_service_check_result_simple(host;service);
