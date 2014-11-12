tile/floor
	name = "Floor"
	desc = "Without this, most smaller things would slip through the support bars."
	preventsPassingFromDir = DOWN
	icon = 'Icons/Tiles/Floor.dmi'
	icon_state = "wood"

	Vanish()
		var/tile/support/S = locate() in loc
		if(!S) S = new(loc)
		. = ..()

	AppliedBy(mob/M, item/I)

		//The floor can't be manipulated with a frame in the way, redirect applications to the frame.
		var/tile/wall_frame/W = locate() in loc
		if(W)
			return W.AppliedBy(M,I)

		if(istype(I,/item/construction/bars/planks))
			var/item/S = M.equipment.GetSupportItem(/item/tool/hammer)
			if(S)
				InverseConstruct(M, WOODFRAME_CON, I, S, "a wooden frame", /tile/wall_frame, HAMMER_SND)
		else if(I.type == /item/construction/bars)
			var/item/S = M.equipment.GetSupportItem(/item/tool/wrench)
			if(S)
				InverseConstruct(M, METALFRAME_CON, I, S, "a metal frame", /tile/wall_frame/metal, WRENCH_SND)


		if(type == /tile/floor)
			if(istype(I,/item/tool/crowbar))
				Deconstruct(M, WOODFLOOR_DEC, I, "a wooden floor", /item/construction/bars/planks, CROWBAR_SND)

	metal
		icon_state = "iron"
		material = /material/iron

		AppliedBy(mob/M, item/I)
			..()
			if(istype(I,/item/tool/crowbar))
				Deconstruct(M, METALFLOOR_DEC, I, "a metal floor", /item/construction/sheets, CROWBAR_SND)

		Footstep()
			Sound(pick('Sounds/Footsteps/Metal1.ogg','Sounds/Footsteps/Metal2.ogg','Sounds/Footsteps/Metal3.ogg',
			'Sounds/Footsteps/Metal4.ogg','Sounds/Footsteps/Metal5.ogg','Sounds/Footsteps/Metal6.ogg'))