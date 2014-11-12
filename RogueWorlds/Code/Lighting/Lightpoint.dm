lightpoint
	var
		x
		y
		z
		turf
			NE
			NW
			SW
			SE
		cached_value = -1

	New(x,y,z)
		var/turf/T = locate(x+0.5,y+0.5,z)
		if(T)
			NE = T
			T.lightSW = src
		T = locate(x-0.5,y+0.5,z)
		if(T)
			NW = T
			T.lightSE = src
		T = locate(x-0.5,y-0.5,z)
		if(T)
			SW = T
			T.lightNE = src
		T = locate(x+0.5,y-0.5,z)
		if(T)
			SE = T
			T.lightNW = src

	proc/max_value()
		if(cached_value < 0)
			var
				valueA = (NW?(NW.lightValue):0)
				valueB = (NE?(NE.lightValue):0)
				valueC = (SW?(SW.lightValue):0)
				valueD = (SE?(SE.lightValue):0)
			cached_value = max(valueA,valueB,valueC,valueD)
		return cached_value

turf/var
	lightValue = 0
	lightpoint
		lightNE
		lightNW
		lightSE
		lightSW
	list/lit_by
	system/lighting/lightOverlay