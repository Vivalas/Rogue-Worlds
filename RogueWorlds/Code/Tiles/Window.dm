tile/window
	name = "Window"
	desc = "Separates areas of the ship."
	density = 1
	opacity = 0
	layer = 2
	icon = 'Icons/Tiles/Window.dmi'
	icon_state = "wood"
	material = /material/glass
	var/frame_type = /tile/wall_frame
	var/border = 0

	PreventsAccess(d)
		return 1

	Vanish()
		new frame_type(loc)
		. = ..()

	New()
		. = ..()
		if(world.time < 10)
			var/area/border/B = loc:loc
			if(istype(B))
				border = 1
				light_border += src
		else
			CheckBorder()

	proc/CheckBorder()
		var/old_border = border
		border = 0
		for(var/area/A in orange(src,1))
			if(A.type == /area/outside) border = 1

		if(border && !old_border)
			light_border += src
			BORDER
		else if(!border && old_border)
			light_border -= src
			SetLight(0,0)

	AppliedBy(mob/M,item/I)
		if(istype(I,/item/tool/screwdriver))
			Deconstruct(M, WINDOW_DEC, I, "a window", /item/construction/sheets/glass, UNSCREW_SND)

	metal
		icon_state = "iron"
		frame_type = /tile/wall_frame/metal