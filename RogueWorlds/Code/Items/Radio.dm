var
	SWITCH_UP = 'Textures/Switch32x32.png'
	SWITCH_DOWN = 'Textures/Switch32x32Down.png'
item/radio
	name = "Radio"
	icon = 'Icons/Items/Radio.dmi'
	interfaceName = "radio"
	var
		frequency = 195.4
		speaker = 0
		mic = 0
		id = "???R"

	UsedBy(mob/M)
		OpenRadio(M)

	InterfaceBy(mob/M, cmd)
		switch(cmd)
			if("Speaker")
				speaker = !speaker
			if("Mic")
				mic = !mic
			if("TuneUp")
				frequency += 1
			if("TuneDown")
				frequency -= 1
			if("FineUp")
				frequency += 0.2
			if("FineDown")
				frequency -= 0.2
		UpdateRadio(M)
	proc
		OpenRadio(mob/M)
			M.OpenInterface(src)
			UpdateRadio(M)
			while(M.interfacing_with == src)
				if(loc != M && get_dist(M,src) > 1) M.CloseInterface()
				sleep(5)

		UpdateRadio(mob/M)
			winset(M,"radio.Frequency","text=\"[frequency]\"")
			if(mic)
				winset(M,"radio.Mic","image=[SWITCH_UP]")
			else
				winset(M,"radio.Mic","image=[SWITCH_DOWN]")
			if(speaker)
				winset(M,"radio.Speaker","image=[SWITCH_UP]")
			else
				winset(M,"radio.Speaker","image=[SWITCH_DOWN]")

		Transmit(msg,mob/source)
			if(ismob(source))
				msg = "<font color=[GetTextColor(source)]>[msg]</font color>"
			clients:
				for(var/client/C)
					var/mob/M = C.mob
					for(var/item/radio/R in M.contents)
						if(R.frequency == frequency)
							C << "\[[frequency]\]\icon[R]: [msg]"
							continue clients
					for(var/item/radio/R in view(M.loc))
						if(R.frequency == frequency && R.speaker)
							C << "\[[frequency]\]\icon[R]: [msg]"
							continue clients