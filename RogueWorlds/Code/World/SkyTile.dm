turf
	name = "Sky"
	icon = 'Icons/World/Sky.dmi'
	icon_state = ""
	layer = 0
	var
		canFallThrough = 1
		canUpdate = 1
		buildings = 0
		gases = 0


	Entered(atom/movable/M)
		. = ..()
		if(canFallThrough && !M.isAnchored)
			var/turf/T = get_step(src,DOWN)
			if(T)
				if(M.CanFall(src,T))
					M.Fall(T)
					if(!M.CanFall(T,get_step(T,DOWN)))
						M.Land(T)
			else
				if(M.CanFall(src,null))
					M.Fall() //TODO: Make the respawn sensible.
					M.Land()

		if(istype(M,/ship/gas)) gases++
	Exited(atom/movable/M)
		. = ..()
		if(istype(M,/ship/gas)) gases--

	New()
		. = ..()
		var/ix = (x % 3)
		var/iy = (y % 3)
		icon_state = "hover [ix],[iy]"

	AppliedBy(mob/M, item/I)
		var/tile/support/U = locate() in src
		if(U) return U.AppliedBy(M,I)

		if(I.type == /item/construction/bars)
			var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
			if(S)
				ConstructSupports(M, I, S)

	proc
		AddBuilding()
			buildings++
			canFallThrough = 0
		RemoveBuilding()
			buildings--
			if(!buildings)
				canFallThrough = 1

		SetState(state)
			var/ix = (x % 3)
			var/iy = (y % 3)
			if(state)
				icon_state = "[state] [ix],[iy]"
			else
				icon_state = "[ix],[iy]"

		ConstructSupports(mob/M, item/tool/tool, item/material)
			M.VisualMessage(construction.sprintf(construction.construct_txt, "some floor supports"))

			if(construction.Check(M, SUPPORT_CON, tool, material, SCREWDRIVER_SND))
				M.VisualMessage(construction.sprintf(construction.c_success_txt, FirstWord(M.name), "some floor supports"))
				new/tile/support(src)
				tool.Consume()
				return 1
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))
				return 0

	marker
		icon = 'Icons/Debug/Marker.dmi'
		icon_state = ""

	markerB
		icon = 'Icons/Debug/Marker.dmi'
		icon_state = "grn"

	dead
		icon = null
		icon_state = ""
		New()
			return
		AddLight()
			return
		UpdateLight()
			return
		RemoveLight()
			return
		ResetValue()
			return
		ResetCachedValues()
			return