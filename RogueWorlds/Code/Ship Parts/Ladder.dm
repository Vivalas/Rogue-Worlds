ship/ladder
	icon = 'Icons/Ship/Ladder.dmi'
	icon_state = "up"
	pixel_y = 12
	isAnchored = 1

	Crossed(mob/M)
		if(ismob(M) && M.dir < 16)
			M.dir = 16
			M.Move(locate(x,y,z+1))

	down
		icon_state = "down"
		Crossed(mob/M)
			if(ismob(M) && M.dir < 16)
				M.dir = 16
				M.Move(locate(x,y,z-1))