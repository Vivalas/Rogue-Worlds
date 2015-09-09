//An outside area. Shows weather, and is lit by sunlight.
area/outside
	icon = 'Icons/Area/Outside.dmi'
	icon_state = "map"
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


	transit
		icon_state = "dark"

		bridge_start

		bridge_end

//A border area. Goes on the outside of the ship, and makes points where outside light floods in.
area/outside/border
	icon_state = "clear"