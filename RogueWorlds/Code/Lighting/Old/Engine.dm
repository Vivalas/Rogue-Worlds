var/list/lights = list()
var/list/outside_points = list()
var/outside_value = 0

turf/proc/AddLight(atom/movable/M)
	lightNE.AddLight(M)
	lightSE.AddLight(M)
	lightNW.AddLight(M)
	lightSW.AddLight(M)

turf/proc/RemoveLight(atom/movable/M)
	lightNE.RemoveLight(M)
	lightSE.RemoveLight(M)
	lightNW.RemoveLight(M)
	lightSW.RemoveLight(M)

proc/aprl_SetOutsideLight(n)
	outside_value = n
	for(var/area/outside/O in world)
		for(var/turf/T in O)
			T.ChangeLightIcon()

turf/proc/GetAffectedLights()
	var/list/L = list()
	if(lightNE.lit_by)
		for(var/V in lightNE.lit_by)
			if(!(V in L))
				L.Add(V)
	if(lightSE.lit_by)
		for(var/V in lightSE.lit_by)
			if(!(V in L))
				L.Add(V)
	if(lightNW.lit_by)
		for(var/V in lightNW.lit_by)
			if(!(V in L))
				L.Add(V)
	if(lightSW.lit_by)
		for(var/V in lightSW.lit_by)
			if(!(V in L))
				L.Add(V)
	return L

proc/aprl_Initialize()
	for(var/z = 1, z <= world.maxz, z++)
		for(var/y = 1, y <= world.maxy, y++)
			for(var/x = 1, x <= world.maxx, x++)
				var/turf/T = locate(x,y,z)

				T.lightNE = new /lightpoint(x+0.5,y+0.5,z)

				var/turf/O

				if(y == 1)
					T.lightSE = new /lightpoint(x+0.5,0.5,z)
				else
					O = locate(x,y-1,z)
					T.lightSE = O.lightNE
				if(x == 1)
					T.lightNW = new /lightpoint(0.5,y+0.5,z)
				else
					O = locate(x-1,y,z)
					T.lightNW = O.lightNE

				if(x == 1 && y == 1)
					T.lightSW = new /lightpoint(0.5,0.5,z)
				else if(y == 1)
					O = locate(x-1, y, z)
					T.lightSW = O.lightSE
				else if(x == 1)
					O = locate(x, y-1, z)
					T.lightSW = O.lightNW
				else
					O = locate(x-1,y-1,z)
					T.lightSW = O.lightNE

				T.light_overlay = new/obj/lighting(T)
				T.ChangeLightIcon()
				T.CheckForOpaqueObjects()

			sleep(-1)
	for(var/atom/movable/A in lights)
		A.SetLuminosity(A.aprl_lightValue,A.aprl_lightRadius)