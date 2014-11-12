tile/wall
	name = "Wall"
	desc = "Separates areas of the ship."
	density = 1
	opacity = 1
	layer = 2
	icon = 'Icons/Tiles/Wall.dmi'
	icon_state = "wood"
	var/frame_type = /tile/wall_frame

	Vanish()
		new frame_type(loc)
		. = ..()

	PreventsAccess(d)
		return 1

	AppliedBy(mob/M, item/I)
		if(istype(I,/item/tool/crowbar))
			Deconstruct(M, WOODWALL_DEC, I, "a wooden wall", /item/construction/bars/planks, CROWBAR_SND)

	metal
		icon_state = "iron"
		material = /material/iron
		frame_type = /tile/wall_frame/metal
		AppliedBy(mob/M, item/I)
			if(istype(I,/item/tool/wrench))
				Deconstruct(M, METALWALL_DEC, I, "a metal wall", /item/construction/sheets, WRENCH_SND)