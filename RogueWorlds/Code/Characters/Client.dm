client
	show_popup_menus = 1
	view = 10
	perspective = EYE_PERSPECTIVE

	var/atom/movable/remote
	var/no_attack = 0
	var/tmp/recieved_radio = 0

	New()
		. = ..()
		var/sound/s = GetWindNoise()
		s.volume = 50
		src << s

	//Checks stun status before continuing.
	Move(turf/T)
		if(remote)
			remote.RemoteMove(get_step(remote,get_dir(mob,T)))
			return
		if(mob.CanMove() && mob.last_moved < world.time - mob.move_delay)
			. = ..()
		else
			return 0

	//Handles clicking.
	//Shift-click attacks, Ctrl-click examines.
	//If attacking: Attack with the current weapon or fists/claws, if in range.
	//If examining: Examine the clicked object.
	//Else: Use the current item on the clicked object, or operate the object if no item is found.
	Click(atom/A, location, control, params)
		winset(src,"Input","focus=true")
		if(!A) return
		var/list/plist = params2list(params)
		var/attacking = mob.fight_target
		var/examining = 0
		if(("shift" in plist)) attacking = 1
		if(("ctrl" in plist) || ("middle" in plist)) examining = 1

		if(no_attack) attacking = 0

		if(!remote)

			if(istype(A,/atom/movable) && istype(mob,/mob/human) && !examining && mob:data:seal)
				var/seal/active/S = mob:data:seal
				if(S.type == /seal/active/wall_break && S.is_active)
					S:Break(A,mob)
					mob.last_acted = world.time
					return 1

			if(!mob.CanClick()) return 0

			if(examining)
				A.ExaminedBy(mob)

			else
				mob.last_acted = world.time
				if(attacking)
					if(ismob(A))
						mob.EnterFight(A)
						return
					else
						var/item/W
						var/range = 1

						if(mob.equipment)
							W = mob.equipment.GetWeapon()
						if(W)
							if(W.weapon) range = W.weapon.range

						if(range <= 1 && !mob.CanAccess(A)) return 0

						if(get_dist(mob,A) <= range)
							if(!A.AttackedBy(mob, W))
								no_attack = 1 //Make sure there's no infinite loop when holding shift.
								return CoarseClick(A, params)

				else if(istype(A,/system/noitem))
					A.OperatedBy(mob)

				else if(get_dist(mob,A) <= 1)
					var/access = mob.CanAccess(A)
					if(mob.equipment)
						var/item/I = mob.equipment.GetItem()
						if(I)
							if(access)
								I.Apply(mob, A)
							else
								I.ApplyAtRange(mob, A)
						else if(access)
							A.OperatedBy(mob)
					else if(access)
						A.OperatedBy(mob)
				else
					if(mob.equipment)
						var/item/I = mob.equipment.GetItem()
						if(I)
							I.ApplyAtRange(mob, A)
		else
			if(examining)
				A.ExaminedBy(mob)
			else if(get_dist(remote,A) <= 1)
				A.RemoteOperatedBy(remote,mob)

		no_attack = 0

	proc/CoarseClick(atom/A, params)
		var/turf/T = A
		if(!isturf(A)) T = A.loc

		var/atom/max
		var/max_layer
		for(var/atom/O in T)
			if(!istype(O,/system) && (mob in viewers(O)))
				if(O.layer >= max_layer)
					max = O
					max_layer = O.layer
		if(ismob(max))
			no_attack = 0
		return Click(max, params=params)


	//Handles mouse dragging.
	//If dragged to a space near the player: Drop the item there.
	//If dragged to an equipment slot: Try to equip the item (must be carrying it).
	MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
		//dbg("Src: [src_object], [src_location], [src_control]")
		//dbg("Over: [over_object], [over_location], [over_control]")
		//dbg("Params: [params]")
		if(remote) return
		if(!mob.CanClick()) return 0
		if(mob.equipment && istype(src_object,/item))
			mob.last_acted = world.time
			var/item/I = src_object
			if(over_control == "default.Map")
				var/atom/movable/O = over_object
				if(get_dist(mob,O) <= 1)
					if(O == mob)
						I.OpenedBy(mob)
					else if(I.slot)
						if(isturf(O))
							I.Drop(mob,O)
						else
							I.Drop(mob,O.loc)
			else if(I.loc == mob)
				//dbg("Getting equip slot: [over_control]")
				var/equipmentslot/E = mob.equipment.GetSlot(over_control)
				I.Equip(mob,E)
		else if(istype(src_object, /atom/movable) && over_object == mob)
			var/atom/movable/M = src_object
			M.OpenedBy(mob)
		else
			. = ..()