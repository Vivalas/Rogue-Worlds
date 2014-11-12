mob/verb
	Drop(main as num)
		set hidden = 1
		if(!equipment) return
		var/item/I
		I = equipment.GetItem()
		I.Drop(src,loc)
	Swap()
		set hidden = 1
	Interface(cmd as text)
		set hidden = 1
		if(istype(interfacing_with,/atom))
			interfacing_with.InterfaceBy(src, cmd)

	CloseWindow()
		set hidden = 1
		if(istype(interfacing_with,/atom))
			CloseInterface()

	UseSeal()
		set hidden = 1

mob/human
	Drop(off as num)
		set hidden = 1
		ResetFocus()
		if(!equipment) return
		var/item/I
		if(istype(equipment,/equipment/player))
			if(off)
				I = equipment.offHandSlot.item
				if(I)
					I.Drop(src,loc)
			else
				I = equipment.GetItem()
				if(I)
					I.Drop(src,loc)
		else
			. = ..()

	Swap()
		set hidden = 1
		ResetFocus()
		if(!istype(equipment,/equipment/player)) return
		var/item/I = equipment.GetItem()
		equipment.mainHandSlot.Unequip(src)
		if(equipment.offHandSlot.item)
			equipment.mainHandSlot.Equip(equipment.offHandSlot.item,src)
		if(I)
			equipment.offHandSlot.Equip(I,src)
		EquipmentChanged(equipment.mainHandSlot)
		EquipmentChanged(equipment.offHandSlot)

	UseSeal()
		set hidden = 1
		ResetFocus()
		if(istype(data.seal,/seal/active))
			src << "Used [data.seal.name]."
			data.seal:Use(src)
			SealChanged()
		else
			src << "Can't use a passive seal."


client/verb
	ScreenSize(n as num)
		set hidden = 1
		switch(n)
			if(32, 48, 64, 0)
				winset(src,"default.Map","icon-size=[n]")
			else
				return 0