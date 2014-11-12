//Object which handles equipment slots on a mob.
equipment
	var/mob/wearer //The mob this equipment object contains the inventory of.

	New(mob/M)
		wearer = M

	proc
		//Gets the item that will be used in Apply() and AppliedBy(), if any.
		GetItem()
			return null

		GetSupportItem(itype)
			return null

		//Gets the outermost torso armor for the mob, if any.
		GetArmor()
			return null

		//Gets the outermost eye protection for the mob, if any.
		GetEyeProtection()
			return null

		//Gets a weapon to be used for attacking. Usually the same as GetItem().
		GetWeapon()
			return null

		//Returns an equipmentslot corresponding to the supplied grid ID.
		GetSlot(control)

		GetLightSource()
			return null

		//Returns true if an item can be equipped on the specified slot.
		CanEquip(equipmentslot/S, item/I)
			return 0

		Update()

//Defines available slots for humans.
equipment/player
	var/equipmentslot
		mainHandSlot = new("MainHand")
		offHandSlot = new("OffHand")

		headSlot = new("Head")
		gogglesSlot = new("Goggles")
		backSlot = new("Back")
		glovesSlot = new("Gloves")

		shirtSlot = new("Shirt")
		trousersSlot = new("Trousers")
		jacketSlot = new("Jacket")
		beltSlot = new("Belt")

	var/item/light_source //The brightest light source.
	var/lightUpdate = 0

	GetItem()
		return mainHandSlot.item

	GetSupportItem(itype)
		if(!itype) return offHandSlot.item
		if(istype(offHandSlot.item,itype))
			return offHandSlot.item
		else
			return null

	GetArmor()
		if(jacketSlot.item) return jacketSlot.item
		else return shirtSlot.item

	GetEyeProtection()
		if(headSlot.item) return headSlot.item
		else return gogglesSlot.item

	GetWeapon()
		if(mainHandSlot.item)
			if(mainHandSlot.item.weapon) return mainHandSlot.item
		return null

	GetLightSource()
		if(lightUpdate) return light_source
		else
			Update()
			return light_source

	Update()
		lightUpdate = 1
		light_source = null
		for(var/item/I in wearer)
			if(light_source)
				if(I.lightRadius > light_source.lightRadius)
					light_source = I
			else if(I.lightRadius > 0)
				light_source = I



	GetSlot(control)
		if(dd_hasprefix(control,"default."))
			control = copytext(control,9)

		switch(control)
			if("MainHand") return mainHandSlot
			if("OffHand") return offHandSlot
			if("Head") return headSlot
			if("Goggles") return gogglesSlot
			if("Back") return backSlot
			if("Gloves") return glovesSlot
			if("Shirt") return shirtSlot
			if("Trousers") return trousersSlot
			if("Jacket") return jacketSlot
			if("Belt") return beltSlot
			else return null

	CanEquip(equipmentslot/S, item/I)
		ASSERT(istype(I,/item))
		ASSERT(!S || istype(S,/equipmentslot))

		//Instant fail conditions: No slot, slot is locked, slot is occupied.
		if(!S) return 0
		if(S.locked) return 0
		if(S.item) return 0

		return I.CanEquipTo(S.name)



//A slot that holds items.
equipmentslot
	var/item/item //The item in this slot.
	var/locked = 0 //If true, no items may be placed or removed in this slot.
	var/name = "Slot" //The name of the grid in the main window that displays this slot.

	var/system/noitem/noitem

	New(n)
		name = n
		noitem = new(src)

	proc
		//Equips an item to this slot, but does not move it into the mob.
		//If the item already has a slot, it is first unequipped.
		Equip(item/I, mob/owner)
			ASSERT(ismob(owner))
			ASSERT(istype(I,/item))
			if(item) return 0
			else
				item = I
				if(I.slot)
					I.slot.Unequip(owner)
				I.slot = src
				if(I.equip_image)
					if(I.gender_separated_states && findtext(I.gender_separated_states,name))
						if(owner.gender == NEUTER)
							I.equip_image.icon_state = "equipped-[lowertext(name)]-male"
						else
							I.equip_image.icon_state = "equipped-[lowertext(name)]-[owner.gender]"
					else
						I.equip_image.icon_state = "equipped-[lowertext(name)]"
					owner.overlays += I.equip_image


		//Unequips the item from this slot, but does not drop it from the mob.
		Unequip(mob/owner)
			ASSERT(ismob(owner))
			if(item)
				item.slot = null
				owner.overlays -= item.equip_image
			item = null

system/noitem
	name = ""
	icon = 'Icons/Items/NoItem.dmi'
	var/equipmentslot/slot
	mouse_opacity = 2
	New(slot)
		. = ..(null)
		src.slot = slot
	OperatedBy(mob/M)
		//dbg("No Item clicked.")
		var/item/I = M.equipment.GetItem()
		if(!I)
		//	dbg("No main hand item.")
			return
		I.Equip(M,slot)