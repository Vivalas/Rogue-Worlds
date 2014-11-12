mob
	var
		equipment/player/equipment
		//healthtracker/health
		//stuntracker/stun
		tiles_fallen = 0

		atom/movable/interfacing_with //The atom which currently has an interface window open.

		in_combat = 0
		can_hear = 1
		last_acted = 0
		move_delay = 2

	Login()
		. = ..()

		if(equipment)
			for(var/v in equipment.vars)
				if(dd_hasSuffix(v,"Slot"))
					var/equipmentslot/E = equipment.vars[v]
					EquipmentChanged(E)

	Move()
		. = ..()
		if(.)
			var/tile/T = locate() in loc
			if(T) T.Footstep()

	ExaminedBy(mob/M)
		. = ..()
		M << "<i>[EvaluateCombat(M,src)]</i>"

	proc
		DisplayName(first_only = 0)
			if(first_only)
				return "<font color=[GetTextColor(src)]>[FirstWord(src.name)]</font color>"
			else
				return "<font color=[GetTextColor(src)]>[src.name]</font color>"

		HasCombatSkill()
			return 0
		HasMechanicsSkill()
			return 0
		HasLabourSkill()
			return 0
		HasScienceSkill()
			return 0
		HasLogicSkill()
			return 0
		HasMedicalSkill()
			return 0

		HasActiveSeal(sealtype)
			return 0

		EquipmentChanged(equipmentslot/slot)
			if(equipment)
				equipment.Update()
				var/item/LS = equipment.GetLightSource()
				if(LS)
					SetLight(LS.lightValue, LS.lightRadius)
				else if(lightValue)
					SetLight(0,0)
			if(client)
				winset(client,"default.[slot.name]","cells=0;current-cell=0")
				if(slot.item)
					client << output(slot.item,"default.[slot.name]")
				else
					client << output(slot.noitem,"default.[slot.name]")

		CanAccess(atom/A)
			ASSERT(istype(A,/atom) && get_dist(src,A) <= 1)
			var/turf/X = A
			var/turf/Y = loc
			if(istype(A,/atom/movable))
				X = A.loc
			var/d = get_dir(src,A)
			for(var/atom/movable/M in (X.contents + Y.contents))
				if(M == A) continue
				if(M.PreventsAccess(d)) return 0
			return 1

		OpenInterface(atom/movable/A)
			ASSERT(istype(A,/atom/movable))
			ASSERT(A.interfaceName && client)
			interfacing_with = A
			winshow(client,A.interfaceName,1)

		CloseInterface()
			ASSERT(istype(interfacing_with,/atom/movable) && client)
			winshow(client,interfacing_with.interfaceName,0)
			interfacing_with = null

		ResetFocus()
			winset(src,"Input","focus=true")