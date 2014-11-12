//An outside area. Shows weather, and is lit by sunlight.
area/outside
	icon = 'Icons/Area/Outside.dmi'
	lightingEnabled = 0
	Entered(mob/M)
		. = ..()
		if(ismob(M))
			var/sound/s = GetWindNoise()
			s.volume = 100
			M << s
	Exited(mob/M)
		. = ..()
		if(ismob(M))
			var/sound/s = GetWindNoise()
			s.volume = 50
			M << s

//A border area. Goes on the outside of the ship, and makes points where outside light floods in.
area/outside/border
