//Events for examining and manipulating atoms through clicks. Also descriptions.
atom
	desc = "Nobody is quite sure what this is."
	proc
		setIconState(txt)
			ASSERT(istext(txt))
			icon_state = txt

		OperatedBy(mob/M)
		AppliedBy(mob/M, item/I)
		AttackedBy(mob/M, item/W)

		RemoteOperatedBy(atom/movable/remote, mob/M)

		ExaminedBy(mob/M)
			M << "<b><u><center>[src]</center></u></b><p><i>[desc]</i></p>"

		GetCardinals()
			. = list()
			for(var/d in list(NORTH,SOUTH,EAST,WEST))
				var/turf/T = get_step(src,d)
				if(T) . += T

proc/IsAccessible(turf/A,turf/B)
	var/d = get_dir(A,B)
	for(var/atom/movable/M in (A.contents + B.contents))
		if((M in A) && M.canMoveOutOf) continue
		if(M.PreventsPassing(d))
			return 0
	return 1

proc/IsAccessibleBy(atom/movable/T,turf/B)
	var/turf/A = T.loc
	var/d = get_dir(A,B)
	for(var/atom/movable/M in (A.contents + B.contents))
		if(M == T) continue
		if((M in A) && M.canMoveOutOf) continue
		if(M.PreventsPassing(d))
			return 0
		if(M.PreventsCrossing(T,d))
			return 0
	return 1