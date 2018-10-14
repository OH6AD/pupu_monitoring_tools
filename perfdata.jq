map_values([.value, .warn, .crit, (
if .crit > .warn then
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
end
), 100]) |
(map(.[3]) | max),
["OK", "WARNING", "CRITICAL"][map(.[3]) | max] + "| " +
(to_entries | map([.key] + (.value | map(tostring)) | join(";")) | join(" "))
