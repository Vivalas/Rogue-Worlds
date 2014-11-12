tile/lift
	icon = 'Icons/Ship/Equipment/Lift.dmi'
	name = "Lift"
	layer = 2
	proc/Shift()
		if(layer == 2)
			icon_state = "under"
			layer = 0.1
		else
			icon_state = null
			layer = 2
	under
		icon_state = "under"
		layer = 0.1

proc/GetLiftSpace(turf/start)
	var/list/open = list(start)
	var/list/closed = list()
	//dbg("Start")
	while(open.len)
		for(var/turf/T in open)
			for(var/turf/O in T.GetCardinals())
				if((O in open) || (O in closed))
					//dbg("Already have one.")
					continue
				var/tile/lift/L = locate() in O
				if(L)
					open += O
					//dbg("Added a turf.")
				else
					//dbg("No lift here.")
			closed += T
			open -= T
	return closed

ship/equipment/console/callbutton
	icon = 'Icons/Ship/Equipment/CallButton.dmi'
	icon_state = "stand"
	lightstate = "green"
	var/ship/equipment/console/lift/linked
	New()
		. = ..()
		spawn(1)
			if(linked)
				for(var/ship/equipment/console/lift/L)
					if(L.liftspace == linked)
						linked = L
						break

	OperatedBy(mob/M)
		if(istype(linked))
			linked.MoveToFloor(src.z)

	ExaminedBy(mob/M)
		. = ..()
		M << "Linked To: [linked]"

ship/equipment/console/lift
	icon = 'Icons/Ship/Equipment/LiftConsole.dmi'
	lightstate = "1"
	var/list/liftspace
	var/moving = 0
	New()
		. = ..()
	OperatedBy(mob/M)
		if(moving) return
		if(!istype(liftspace,/list)) liftspace = GetLiftSpace(loc)
		if(z == 1)
			Ascend()
		else
			Descend()
	ExaminedBy(mob/M)
		for(var/turf/T in liftspace)
			var/system/tele/E = new(T)
			spawn E.Teleport("malein")
	proc
		Ascend()
			moving = 1
			Sound('Sounds/Structure/Lift1.ogg')
			sleep(14)
			for(var/turf/T in liftspace)
				var/tile/lift/L = locate() in T
				L.Shift()
				for(var/atom/movable/A in T)
					if(A.Mobile())
						//dbg("Moving [A]...")
						A.ForceMove(locate(A.x,A.y,A.z+1))
					else
						//dbg("Not Moving [A]...")
			liftspace = GetLiftSpace(loc)
			for(var/turf/T in liftspace)
				var/tile/lift/L = locate() in T
				L.Shift()
			moving = 0
			Sound('Sounds/Structure/Lift2.ogg')
		Descend()
			moving = 1
			Sound('Sounds/Structure/Lift1.ogg')
			sleep(14)
			for(var/turf/T in liftspace)
				var/tile/lift/L = locate() in T
				L.Shift()
				for(var/atom/movable/A in T)
					if(A.Mobile())
						dbg("Moving [A]...")
						A.ForceMove(locate(A.x,A.y,A.z-1))
					else
						dbg("Not Moving [A]...")
			liftspace = GetLiftSpace(loc)
			for(var/turf/T in liftspace)
				var/tile/lift/L = locate() in T
				L.Shift()
			moving = 0
			Sound('Sounds/Structure/Lift2.ogg')

		MoveToFloor(n)
			ASSERT(isnum(n))
			if(moving)
				dbg("Your FACE is moving.")
				return
			if(!istype(liftspace,/list)) liftspace = GetLiftSpace(loc)
			dbg("Moving to floor [n]")
			moving = 1
			while(src.z != n)
				if(src.z > n)
					dbg("Descending...")
					Descend()
				else if(src.z < n)
					dbg("Ascending...")
					Ascend()
				dbg("Done.")
				moving = 1
				sleep(15)
			moving = 0