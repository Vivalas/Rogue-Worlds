proc
	Capitalize(str)
		return uppertext(copytext(str,1,2)) + copytext(str,2)

	Article(str)
		if(lowertext(copytext(str,length(str))) == "s")
			return "Some"
		else if(lowertext(copytext(str,1,2)) in w_vowels)
			return "An"
		else
			return "A"

	Pronoun(datum/D)
		if("gender" in D.vars)
			switch(D.vars["gender"])
				if(MALE)
					return "him"
				if(FEMALE)
					return "her"
				else
					return "them"
		else
			return "it"

	PosPronoun(datum/D)
		if("gender" in D.vars)
			switch(D.vars["gender"])
				if(MALE)
					return "his"
				if(FEMALE)
					return "her"
				else
					return "their"
		else
			return "its"

	FirstWord(str)
		return copytext(str,1,findtext(str," "))

	ItemName(str)
		return copytext(str,findtext(str," ")+1)

	RemoveExtraSpaces(str)
		var/spaces = 0
		var/newstr = ""
		for(var/i = 1 to length(str))
			var/char = copytext(str,i,i+1)
			if(char == " ")
				if(spaces) continue
				else
					newstr += char
					spaces = 1
			else
				newstr += char
				spaces = 0
		return newstr

	Mumble(str, amt)
		var/list/wlist = dd_text2list(str," ")
		for(var/i = 1, i <= length(wlist), i++)
			if(prob(amt))
				wlist[i] = "..."

		return dd_list2text(wlist, " ")

	GetTextColor(mob/human/M)
		if(istype(M,/mob/human))
			if(M.data) return M.data.textcolor
		return "#555555"


mob/verb
	Say(msg as text)
		var/transmit = 0
		if(dd_hasprefix(msg,";"))
			transmit = 1
			if(dd_hasprefix(msg,"; "))
				msg = copytext(msg,3)
			else
				msg = copytext(msg,2)
		if(client) CaptureTxt(msg)
		for(var/client/C)
			var/mob/M = C.mob
			if(M.can_hear)
				if(M in hearers(src))
					M << "<b>[src]</b> says, \"<font color=[GetTextColor(src)]>[msg]</font color>\""
				else if(get_dist(src,M) <= SOUND_DISTANCE)
					var/perception = 2.5
					var/distortion = max(0,sd_get_dist(src,M) - 1) * 6 * (5 - perception)
					if(distortion <= 45)
						var/rc = rgb(rand(120,255),rand(120,255),rand(120,255))
						M << "<small>A [src.gender] voice says, \"<font color=[(prob(distortion))?(rc):(GetTextColor(src))]>[Mumble(msg,distortion)]</font color>\"</small>"
					else if(distortion <= 75)
						M << "<small>A voice says, \"<font color=#555555>[Mumble(msg,distortion)]</font color>\"</small>"
		if(!fight)
			for(var/item/radio/R in view(src))
				if(R.mic || (transmit && R.loc == src))
					R.Transmit(msg,src)

	Shout(msg as text)
		var/transmit = 0
		if(dd_hasprefix(msg,";"))
			transmit = 1
			if(dd_hasprefix(msg,"; "))
				msg = copytext(msg,3)
			else
				msg = copytext(msg,2)
		if(client) CaptureTxt(msg)
		for(var/client/C)
			var/mob/M = C.mob
			if(M.can_hear)
				if(M in hearers(src))
					M << "<b>[src]</b> shouts, <big>\"<b><font color=[GetTextColor(src)]>[msg]</font color></b>\"</big>"
				else if(get_dist(src,M) <= SOUND_DISTANCE)
					var/perception = 4
					var/distortion = max(0,sd_get_dist(src,M) - 1) * 6 * (5 - perception)
					if(distortion <= 75)
						var/rc = rgb(rand(120,255),rand(120,255),rand(120,255))
						M << "A [src.gender] voice shouts, \"<b><font color=[(prob(distortion))?(rc):(GetTextColor(src))]>[Mumble(msg,distortion/3)]</font color></b>\""
					else if(distortion <= 99)
						M << "A voice shouts, \"<b><font color=#555555>[Mumble(msg,distortion/2)]</font color></b>\""
		if(!fight)
			for(var/item/radio/R in view(src))
				if(R.mic || (transmit && R.loc == src))
					R.Transmit(msg,src)

	Whisper(msg as text)
		var/transmit = 0
		if(dd_hasprefix(msg,";"))
			transmit = 1
			if(dd_hasprefix(msg,"; "))
				msg = copytext(msg,3)
			else
				msg = copytext(msg,2)
		if(client) CaptureTxt(msg)
		for(var/client/C)
			var/mob/M = C.mob
			if(M.can_hear)
				var/perception = 2
				var/distortion = max(0,sd_get_dist(src,M) - 1) * 6 * (5 - perception)
				if(M in range(src,1))
					M << "<b>[src]</b> whispers, <i>\"<font color=[GetTextColor(src)]>[msg]</font color>\"</i>"
				else if(M in hearers(src) && distortion <= 40)
					M << "<i><small>[src] whispers, \"<font color=[GetTextColor(src)]>[Mumble(msg,distortion*2.2)]</font color>\"</small></i>"
				else if(distortion <= 40)
					M << "<i><small>A voice whispers, \"<font color=#555555>[Mumble(msg,distortion*3.5)]</font color>\"</small></i>"

		if(!fight)
			for(var/item/radio/R in view(1,src))
				if(R.mic || (transmit && R.loc == src))
					R.Transmit(msg,src)

proc/Announce(txt)
	for(var/client/C)
		var/mob/M = C.mob
		if(M.can_hear)
			M << "<center><big><b>Attention:</b><br>[txt]</big></center>"

atom/proc
	VisualMessage(msg, blindmsg)
		for(var/mob/M in hearers(src))
			if(M in viewers(src))
				M << msg
			else
				M << blindmsg

	AudioMessage(msg, deafmsg)
		for(var/mob/M in hearers(src))
			if(M.can_hear)
				M << msg
			else if(M in viewers(src))
				M << deafmsg