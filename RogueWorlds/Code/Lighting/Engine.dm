#define LIGHTCLAMP(x) ( max(0,min(3,round(x,1))) )

var/outside_light = 0
var/list/initial_lights = list()
var/list/icon_updates = list()

var/list/light_border = list()

proc/aprl_Initialize(outside)
	for(var/z = 1, z <= world.maxz, z++)
		for(var/y = 0, y <= world.maxy, y++)
			for(var/x = 0, x <= world.maxx, x++)
				if(x > 0 && y > 0)
					var/turf/T = locate(x,y,z)
					T.lightOverlay = new(T)
					T.CheckForOpaqueObjects()
				new/lightpoint(x+0.5,y+0.5,z)

	for(var/atom/movable/M in initial_lights)
		M.SetLight()
	OutsideLight(outside)
	initial_lights.len = 0
	initial_lights = null

proc/OutsideLight(n)
	outside_light = n
	for(var/atom/movable/A in light_border)
		A.SetLight(5,n-1)
	for(var/area/outside/A)
		for(var/turf/T in A)
			T.ResetValue()
	FlushIconUpdates()

proc/FlushIconUpdates()
	for(var/T in icon_updates)
		if(T)
			T:UpdateLight()
			T:addedToIconUpdates = 0
	icon_updates = list()

atom/movable/var
	lightRadius = 0
	lightValue = 0
	list/aprl_litTurfs

atom/movable/New()
	. = ..()
	if(lightValue > 0)
		initial_lights.Add(src)
	if(opacity)
		opacity = 0
		SetOpacity(1)

atom/movable/Move()
	var/o = opacity
	if(o) SetOpacity(0)
	. = ..()
	if(.)
		if(o) SetOpacity(1)
		if(lightValue > 0)
			ResetLight()
			FlushIconUpdates()

atom/movable/proc
	SetLight(v = lightValue, r = lightRadius)
		src.lightRadius = r
		src.lightValue = v
		ResetLight()
		FlushIconUpdates()

	ResetLight()
		var/list/affected = list()
		for(var/turf/T in aprl_litTurfs)
			T.RemoveLight(src)
			affected.Add(T)
		aprl_litTurfs = list()
		if(lightValue > 0)

			for(var/turf/T in view(src,lightRadius+1))
				T.AddLight(src)
				aprl_litTurfs.Add(T)
				affected.Add(T)

	SetOpacity(o)
		if(o == opacity) return
		opacity = o
		var/turf/T = loc
		for(var/atom/movable/A in T.lit_by)
			A.ResetLight()
		FlushIconUpdates()
		for(var/mob/M in viewers(src))
			M.UpdateAmbientSound(M.loc)

	aprl_CalculateBrightness(turf/T)
		var/square = get_square_dist(x,y,z,T.x,T.y,T.z)
		if(square > (lightRadius+2)*(lightRadius+2)) return 0
		//+2 offset gives an ambient light effect.

		var/value = ((lightRadius)/(2*sqrt(square) + 1)) * lightValue - 0.48
		/*
			  lightRadius
			---------------- * lightValue - 0.48
			2 * distance + 1

			The light decreases by twice the distance, starting from the radius.
			The + 1 causes the graph to shift to the left one unit so that division by zero is prevented on the source tile.

			This is then multiplied by the light value to give the final result.
			The -0.48 offset causes the value to be near zero at the radius.

			This gives a result which is likely close to the inverse-square law in two dimensions instead of three.
		*/


		return max(min( value , lightValue), 0) //Ensure the value never goes above the maximum light value or below zero.

		//return cos(90 * sqrt(square) / max(1,lightRadius)) * lightValue

system/lighting
	isSystemObj = 1
	isAnchored = 1
	layer = 9
	mouse_opacity = 0
	icon = 'Icons/Lighting/SimpleDark.dmi'
	icon_state = "0000"

turf/proc
	UpdateLight()
		if(lightOverlay)
			lightOverlay.icon_state = "[lightSE.max_value()][lightSW.max_value()][lightNW.max_value()][lightNE.max_value()]"

	AddLight(atom/movable/M)
		if(!lit_by) lit_by = list()
		lit_by.Add(M)
		if(!hasOpaqueObjects)
			var/brightness = M.aprl_CalculateBrightness(src)
			if(brightness > lightValue)
				lightValue = LIGHTCLAMP(brightness)
				ResetCachedValues()
			AddToIconUpdates()
			for(var/turf/T in orange(1,src))
				if(!T.addedToIconUpdates)
					T.AddToIconUpdates()

	RemoveLight(atom/movable/M)
		lit_by.Remove(M)
		ResetValue()
		if(!lit_by.len) lit_by = null

	ResetValue()
		CheckForOpaqueObjects()
		if(hasOpaqueObjects)
			lightValue = 0
		else
			var/max_brightness = (isOutside?(outside_light):0)
			for(var/atom/movable/A in lit_by)
				var/brightness = A.aprl_CalculateBrightness(src)
				if(brightness > max_brightness)
					max_brightness = brightness
			lightValue = LIGHTCLAMP(max_brightness)
		ResetCachedValues()
		AddToIconUpdates()
		for(var/turf/T in orange(1,src))
			T.AddToIconUpdates()

	ResetCachedValues()
		lightNE.cached_value = -1
		lightNW.cached_value = -1
		lightSE.cached_value = -1
		lightSW.cached_value = -1

	AddToIconUpdates()
		if(!addedToIconUpdates)
			addedToIconUpdates = 1
			icon_updates.Add(src)

tile/ExaminedBy(mob/M)
	. = ..()
	var/turf/T = loc
	M << "Icon State: [T.lightOverlay.icon_state]"
	M << "Lights:"
	for(var/atom/movable/O in T.lit_by)
		M << "-[O]"

tile/OperatedBy(mob/M)
	var/turf/T = loc
	T.UpdateLight()
	M << "Light updated."

turf/var/hasOpaqueObjects = 0
turf/var/isOutside = 0
turf/var/addedToIconUpdates = 0

turf/proc/CheckForOpaqueObjects()
	hasOpaqueObjects = 0
	for(var/atom/movable/M in contents)
		if(M.opacity)
			hasOpaqueObjects = 1
			break
	isOutside = istype(loc,/area/outside)