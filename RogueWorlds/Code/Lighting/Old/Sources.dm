atom/movable/var
	aprl_lightValue = 0
	aprl_lightRadius = 0
	list/aprl_lightList

atom/movable/Move()
	. = ..()
	if(.)
		if(aprl_lightValue > 0 || aprl_lightList) aprl_ResetLight()

atom/movable/proc
	SetLuminosity(n, r)
		ASSERT(n >= 0 && r >= 0)
		aprl_lightValue = n
		aprl_lightRadius = r
		dbg("Light set to [n], [r]")
		aprl_ResetLight()

	aprl_LightCalculation(lx,ly,lz)
		var/square = get_square_dist(x,y,z,lx,ly,lz)
		if(square > aprl_lightRadius*aprl_lightRadius) return 0
		return cos(90 * sqrt(square) / max(1,aprl_lightRadius)) * aprl_lightValue

	aprl_ResetLight()
		for(var/turf/T in aprl_lightList)
			T.RemoveLight(src, 0)
		aprl_lightList = null
		if(aprl_lightValue > 0)
			aprl_lightList = list()
			for(var/turf/T in view(src,aprl_lightRadius))
				if(!T.hasOpaqueObjects)
					T.AddLight(src)
				aprl_lightList.Add(T)

	SetOpacity(o)
		if(opacity == o) return
		opacity = o
		var/turf/T = loc
		if(isturf(T))
			var/list/affectedLights = T.GetAffectedLights()
			for(var/atom/movable/M in affectedLights)
				M.aprl_ResetLight()
		else
			dbg("[T] is not a turf.")