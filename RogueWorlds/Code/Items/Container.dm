item/container
	var/contained_weight = 0
	var/total_weight_capacity = 100
	var/item_weight_capacity = 20
	interfaceName = "container"

	AppliedBy(mob/M,item/I)
		if(CheckInsert(I))
			M.Sound('Sounds/Inventory/Equip.ogg')
			var/equipmentslot/slot = I.slot
			slot.Unequip(M)
			Insert(I)
			UpdatePack(M)
			M.EquipmentChanged(slot)
		else
			M << "\red [I] doesn't fit in [src]."

	OperatedBy(mob/M,atk)
		if(src.loc == M && !atk)
			OpenPack(M)
		else
			. = ..()

	AttackedBy(mob/M,item/W)
		if(!W && loc == M)
			OperatedBy(M,1)
			return 1
		else
			return ..()

	OpenedBy(mob/M)
		M.VisualMessage("[M] opens [src].")
		OpenPack(M)

	proc
		CheckInsert(item/I)
			return I.unit_weight <= item_weight_capacity && contained_weight + I.weight <= total_weight_capacity
		Insert(item/I)
			contained_weight += I.weight
			I.Move(src)
		Remove(item/I, newLoc)
			if(I in contents)
				I.Move(newLoc)
				contained_weight -= I.weight

		OpenPack(mob/M)
			M.OpenInterface(src)
			winset(M,"container.Title","text=\"[ItemName(name)]\"")
			UpdatePack(M)
			var/items = contents.len
			while(M.interfacing_with == src)
				if(items != contents.len)
					UpdatePack(M)
					items = contents.len
				if(src.loc != M && get_dist(src,M) > 1) break
				sleep(5)
				if(M.last_moved > world.time - 5) break
			if(M.client && M.interfacing_with == src) M.CloseInterface()

		UpdatePack(mob/M)
			if(M.interfacing_with != src) return
			winset(M,"container.Contents","current-cell=0;cells=[contents.len]")
			var/items = 1
			for(var/item/I in src)
				winset(M,"container.Contents","current-cell=[items++]")
				M << output(I,"container.Contents")
