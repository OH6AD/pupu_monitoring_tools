# Inject success state
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
end)})
