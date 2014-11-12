item/writing/page
	name = "Paper"
	desc = "Some paper for writing."
	weight = 1
	icon = 'Icons/Books/LoosePage.dmi'
	var/written = ""
	var/printed = 0
	var/item/writing/pen/writing_with
	interfaceName = "page-loose"
	OperatedBy(mob/M)
		if(loc == M || isAnchored)
			OpenPage(M)
		else
			. = ..()
	UsedBy(mob/M)
		OpenPage(M)

	ExaminedBy(mob/M)
		if(written) OpenPage(M)
		else return ..()

	UpdateStacks()
		if(isAnchored) icon_state = "posted"
		else if(written) icon_state = "writing"
		else icon_state = null

	AppliedBy(mob/M,item/I)
		if(istype(I,/item/writing/pen))
			OpenPage(M,I)
		if(istype(I,/item/tool/hammer) || istype(I,/item/tool/crowbar) && isAnchored)
			isAnchored = 0
			pixel_x = 0
			pixel_y = 0
			icon_state = null
		. = ..()

	AppliedTo(mob/M,atom/movable/A)
		if(istype(A,/tile/wall) || istype(A,/tile/wall_frame))
			var/item/tool/hammer/H = M.equipment.GetSupportItem(/item/tool/hammer)
			if(H)
				M.Sound('Sounds/Tools/Hammer.ogg')
				var/old_slot = slot
				slot.Unequip(M)
				loc = M.loc
				M.EquipmentChanged(old_slot)
				isAnchored = 1
				var/d = get_dir(M,A)
				if(d & NORTH)
					pixel_y = 32
				if(d & EAST)
					pixel_x = 32
				if(d & SOUTH)
					pixel_y = -32
				if(d & WEST)
					pixel_x = -32
				icon_state = "posted"
				M.VisualMessage("[M] posts a paper on the wall.")
		. = ..()
	proc
		OpenPage(mob/M, writing)
			src.writing_with = writing
			M.OpenInterface(src)
			winset(M,"page-loose.WriteText","text=\"[written]\"")
			SetupPage(M)
			while(M.client && M.interfacing_with == src)
				sleep(5)
				UpdateInk(M)
				if(writing_with)
					if(writing_with.loc != M && get_dist(M,writing_with) > 1)
						writing_with = null
						SetupPage(M)
				if(src.loc != M && get_dist(M,src) > 1)
					M.CloseInterface()
			ClosePage(M)
			writing_with = null

		SetupPage(mob/M)
			if(writing_with)
				winset(M,"page-loose.WriteText","is-visible=true")
			else
				winset(M,"page-loose.ReadText","text=\"[written]\"")
				winset(M,"page-loose.WriteText","is-visible=false")

		ClosePage(mob/M)
			if(writing_with)
				var/new_text = winget(M,"page-loose.WriteText","text")
				written = new_text
				M.VisualMessage("[M] writes something down on paper.")
			UpdateStacks()

		UpdateInk(mob/M)

	chemistry_note
		printed = 1
		isAnchored = 1
		icon_state = "posted"
		pixel_x = 32
		written = {"Dear Chemists,
		While it may seem like a good idea, please
		DO NOT mix all the chemicals in one flask and put it on the burner.\
		 The chemical you will recieve will be difficult to reproduce and will also most likely poison you and/or blow up in your face.

		It is also not the brightest idea to test chemicals by eating them, as at best they will be indigestible and at \
		worst highly toxic.

		Finally, in the event that you or your fellow scientists spill gas into the lab, pull this lever and seek medical \
		attention."}