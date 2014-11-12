turf/var/lightpoint
	lightNE
	lightNW
	lightSE
	lightSW

turf/var/hasOpaqueObjects = 0

turf/proc/CheckForOpaqueObjects()
	hasOpaqueObjects = 0
	for(var/atom/movable/M in contents)
		if(M.opacity)
			hasOpaqueObjects = 1
			break

obj/lighting
	icon = 'Icons/Lighting/LightOverlay.dmi'
	isAnchored = 1
	isSystemObj = 1
	icon_state = "0000"
	layer = 11
	mouse_opacity = 0

turf/var/obj/lighting/light_overlay

turf/proc/ChangeLightIcon()
	if(istype(loc,/area/outside))
		light_overlay.icon_state = "[max(lightSE.value,outside_value)][max(lightSW.value,outside_value)][max(lightNW.value,outside_value)][max(lightNE.value,outside_value)]"
	else
		light_overlay.icon_state = "[lightSE.value][lightSW.value][lightNW.value][lightNE.value]"