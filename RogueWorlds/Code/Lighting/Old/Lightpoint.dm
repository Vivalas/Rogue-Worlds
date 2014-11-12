lightpoint
	var
		value = 0
		list/lit_by

		x = 0
		y = 0
		z = 0

		turf
			turfNE
			turfNW
			turfSE
			turfSW

	New(nx,ny,nz)
		x = nx
		y = ny
		z = nz
		turfNE = locate(x+0.5,y+0.5,z)
		turfNW = locate(x-0.5,y+0.5,z)
		turfSE = locate(x+0.5,y-0.5,z)
		turfSW = locate(x-0.5,y-0.5,z)
		RecalculateLight()

	proc
		AddLight(atom/movable/M, iconchange = 1)
			if(!lit_by)
				lit_by = list()
			if(!(M in lit_by))
				lit_by.Add(M)
				var/mval = M.aprl_LightCalculation(x,y,z)
				if(mval > value)
					value = max(0,min(5,round(mval,1)))
				if(iconchange) ChangeAllLightIcons()
		RemoveLight(atom/movable/M, iconchange = 1)
			if(!lit_by) return
			lit_by.Remove(M)
			if(lit_by.len == 0)
				lit_by = null
			RecalculateLight(iconchange)

		SetOutsideValue(n)
			outside_value = n
			RecalculateLight(0) //Icons are changed by the main proc.

		RecalculateLight(iconchange = 1)
			value = outside_value
			if(lit_by)
				for(var/v in lit_by)
					var/atom/movable/M = v
					var/mval = M.aprl_LightCalculation(x,y,z)
					if(mval > value)
						value = mval
			value = max(0,min(5,round(value,1)))
			if(iconchange) ChangeAllLightIcons()

		ChangeAllLightIcons()
			if(turfNE)
				if(turfNE.light_overlay) turfNE.ChangeLightIcon()
			if(turfNW)
				if(turfNW.light_overlay) turfNW.ChangeLightIcon()
			if(turfSE)
				if(turfSE.light_overlay) turfSE.ChangeLightIcon()
			if(turfSW)
				if(turfSW.light_overlay) turfSW.ChangeLightIcon()

		LightData()
			var/txt = ""
			if(lit_by)
				for(var/v in lit_by)
					txt += "[v] - "
			return txt