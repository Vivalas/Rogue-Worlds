var/list/chain = list()

mob
	var/last_said = ""

	proc/MarkovCapture(txt)
		var/l = chain.Find(last_said)
		if(l == 0)
			chain.Add(last_said)
			chain[last_said] = list(txt)
		else
			chain[l] += txt
		last_said = txt