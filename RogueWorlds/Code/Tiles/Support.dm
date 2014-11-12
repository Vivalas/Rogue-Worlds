tile/support
	icon = 'Icons/Tiles/Support.dmi'
	icon_state = "iron"
	desc = "The last barrier between you and falling to your death. Items can sometimes slip through them."
	name = "Support Bars"
	preventsPassingFromDir = DOWN
	material = /material/iron
	layer = 0.5
	Footstep()
		Sound(pick('Sounds/Footsteps/Support1.ogg','Sounds/Footsteps/Support2.ogg','Sounds/Footsteps/Support3.ogg',
		'Sounds/Footsteps/Support4.ogg','Sounds/Footsteps/Support5.ogg','Sounds/Footsteps/Support6.ogg'))

	AppliedBy(mob/M, item/I)

		//The supports can't be manipulated with a floor in the way, redirect applications to the floor.
		var/tile/floor/F = locate() in loc
		if(F)
			return F.AppliedBy(M,I)

		if(istype(I,/item/tool/screwdriver))
			var/item/S = M.equipment.GetSupportItem(/item/construction)
			if(!S)
				Deconstruct(M, SUPPORT_DEC, I, "the floor supports", /item/construction/bars, UNSCREW_SND)
		else if(I.type == /item/construction/bars/planks)
			var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
			if(S)
				InverseConstruct(M, WOODFLOOR_CON, I, S, "a wooden floor", /tile/floor, SCREWDRIVER_SND)
		else if(I.type == /item/construction/sheets)
			var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
			if(S)
				InverseConstruct(M, METALFLOOR_CON, I, S, "a metal floor", /tile/floor/metal, SCREWDRIVER_SND)
		else
			Deconstruct(M, SUPPORT_DEC, I, "the floor supports", /item/construction/bars, UNSCREW_SND)

	//Requires special deconstruction because materials dropped on the sky will fall.
	Deconstruct(mob/M, basetime, item/tool/tool, structname, drop, sound)
		M.VisualMessage(construction.sprintf(construction.deconstruct_txt, M.name, structname))

		if(construction.Check(M, basetime, tool, null, sound))
			M.VisualMessage(construction.sprintf(construction.dc_success_txt, FirstWord(M.name), structname))
			var/item/I = new drop(M.loc)
			if(istype(I) && M.equipment.GetSupportItem() == null)
				I.GetSupport(M)
			Vanish()
		else
			M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))