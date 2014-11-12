tile/wall_frame
	name = "Wall Frame"
	desc = "Separates areas of the ship."
	density = 1
	opacity = 0
	layer = 2
	icon = 'Icons/Tiles/WallFrame.dmi'
	icon_state = "wood"

	PreventsAccess(d)
		return 0

	New()
		. = ..()
		//spawn(1)
			/*var/area/border/B = loc:loc
			if(istype(B))
				SetLight(5,8)*/

	AppliedBy(mob/M, item/I)
		if(istype(I, /item/construction/bars/planks))
			var/item/S = M.equipment.GetSupportItem(/item/tool/hammer)
			if(S)
				if(InverseConstruct(M, WOODWALL_CON, I, S, "a wooden wall", /tile/wall, HAMMER_SND))
					Vanish()

		if(istype(I, /item/construction/sheets/glass))
			var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
			if(S)
				if(InverseConstruct(M, WINDOW_CON, I, S, "a window", /tile/window, SCREWDRIVER_SND))
					Vanish()

		if(istype(I, /item/construction/sprockets))
			var/item/S = M.equipment.GetSupportItem(/item/tool/wrench)
			if(S)
				if(InverseConstruct(M, WOODDOOR_CON, I, S, "a wooden door", /ship/door, WRENCH_SND))
					Vanish()

		if(istype(I, /item/tool/crowbar))
			Deconstruct(M, WOODFRAME_DEC, I, "a wooden frame", /item/construction/bars/planks, CROWBAR_SND)

	metal
		icon_state = "iron"
		material = /material/iron

		AppliedBy(mob/M, item/I)
			if(I.type == /item/construction/sheets)
				var/item/S = M.equipment.GetSupportItem(/item/tool/wrench)
				if(S)
					if(InverseConstruct(M, METALWALL_CON, I, S, "a metal wall", /tile/wall/metal, WRENCH_SND))
						Vanish()
			else if(istype(I,/item/tool/wrench))
				Deconstruct(M, METALFRAME_DEC, I, "a metal frame", /item/construction/bars, WRENCH_SND)

			else if(istype(I, /item/construction/sheets/glass))
				var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
				if(S)
					if(InverseConstruct(M, WINDOW_CON, I, S, "a window", /tile/window/metal, SCREWDRIVER_SND))
						Vanish()
			else if(istype(I, /item/construction/sprockets))
				var/item/S = M.equipment.GetSupportItem(/item/tool/wrench)
				if(S)
					if(InverseConstruct(M, METALDOOR_CON, I, S, "a metal door", /ship/door/iron, WRENCH_SND))
						Vanish()
