proc/availableStepRand(atom/movable/A)
	if(!isturf(A.loc)) return A.loc
	var/list/available = list()
	for(var/turf/T in orange(1,A.loc))
		if(A.CanMoveTo(T))
			available.Add(T)
	if(!available.len) return A.loc
	return pick(available)

atom/movable
	var
		isAnchored = 0 //Prevents the atom from being moved or falling.
		isSystemObj = 0 //Causes the object to ignore most checks.
		preventsPassingFromDir = 0 //Contains flags for the directions from which this object should prevent movement.
		canMoveOutOf = 0
		interfaceName //On objects with special windows, this is the name of the window to open.
		weight = 0
		last_moved = 0

	//Move() now checks for directional blockage.
	Move(newloc)
		if(istype(newloc,/turf) && istype(loc,/turf))
			if(CanMoveTo(newloc))
				last_moved = world.time
				return ..()
			else
				return 0
		else
			return ..()
	proc
		ForceMove(turf/newloc)
			var/turf/L = loc
			L.Exited(src)
			loc = newloc
			newloc.Entered(src)
		Mobile()
			return !isAnchored && !isSystemObj
		//Checks if the object is able to fall.
		CanFall(turf/A, turf/B)
			ASSERT(istype(A,/turf))

			if(isAnchored) return 0
			if(!B)
				if(!A.canFallThrough) return 0
				return 1
			else
				ASSERT(istype(B,/turf))
				if(!A.canFallThrough) return 0
				for(var/atom/movable/M in B)
					if(M.PreventsPassing(UP)) return 0
				return 1

		//Checks if an object can move to a location.
		CanMoveTo(turf/B)
			return IsAccessibleBy(src,B)

		//Checks if an object prevents movement from specific directions.
		PreventsPassing(d)
			ASSERT(isnum(d))
			if((d & preventsPassingFromDir) > 0) return 1
			if(density) return 1
			return 0

		PreventsCrossing(atom/movable/A)
			return 0

		//Checks if an object prevents reaching through to get items, etc. from a direction.
		PreventsAccess(d)
			return 0

		//Does the actual movement for falling.
		//Turf argument can be null if the object fell off the map.
		Fall(turf/T)
			if(T)
				Move(T)
			else
				loc = null

		//Called on impact with the ground, and with no argument on falling off the map.
		Land(turf/T)

		//Called from the Interface "[cmd] verb, whenever a user manipulates a control in the object's interface window.
		InterfaceBy(mob/M, cmd)

		//Called when the user drags this object over their icon.
		OpenedBy(mob/M)

		RemoteMove(turf/T) //Called when the object is moved by a client via its remote variable.

		Destroy() //Called when the object is destroyed by a powerful force rather than deleted or deconstructed.
			del src

		//If this doesn't move for the set time, return 1. Otherwise, immediately return 0 when it moves.
		MoveTimer(time = -1)
			var/initial_move = last_moved
			while(time < 0 || time > 0)
				if(last_moved > initial_move)
					return 0
				sleep(1)
				if(time > 0) time--

			return 1