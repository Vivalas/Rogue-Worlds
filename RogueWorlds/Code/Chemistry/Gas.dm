proc/PlaceGas(turf/T, chemical/gas)
	var/volume = gas.Volume()
	dbg("Gas Color: [gas.color]")
	while(volume > 0)
		var/ship/gas/puff = new(T,gas.SplitVolume(0.5))
		puff.icon_state = lowertext(gas.color)
		volume -= 0.5

/ship/gas
	icon = 'Icons/Chemicals/Gases.dmi'
	animate_movement = NO_STEPS
	layer = MOB_LAYER+1
	mouse_opacity = 0
	var/ship/fan
	New(turf/L)
		. = ..()
		L.gases++
		spawn Spread()

	proc/Spread()
		while(1)
			sleep(rand(6,10))
			if(fan)
				step_towards(src,fan)
				if(get_dist(src,fan) <= 0) Vanish()
			else
				var/attempts = 6
				while(attempts > 0)
					attempts--
					sleep(1)
					var/turf/T = pick(GetCardinals())
					if(!CanMoveTo(T)) continue
					Move(T)
					break

	CanMoveTo(turf/T)
		if(!fan && (T.gases >= loc:gases)) return 0
		for(var/atom/movable/M in T)
			if(M == src) continue
			if(istype(M,/tile/wall)) return 0
			else if(istype(M,/tile/window)) return 0
			else if(istype(M,/ship/door))
				var/ship/door/D = M
				if(!D.open) return 0
		return 1