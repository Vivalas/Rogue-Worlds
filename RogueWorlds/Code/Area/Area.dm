//Basic area. Has lighting on, and is dark when unlit. Use area/outside for areas exposed to daylight.
area
	icon = 'Icons/Area/Inside.dmi'
	icon_state = "map"
	layer = 10
	mouse_opacity = 0
	var/lightingEnabled = 1

	//Used in lighting.
	dark
		icon_state = "map"
		luminosity = 1

	start
	border