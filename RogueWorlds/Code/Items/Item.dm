/*
Tools
Lighting
Fire Extinguisher
Materials
Weapons
*/

var/list/obj_vars = list()

proc/GenerateCopyList()
	var/obj/O = new()
	for(var/v in O.vars)
		obj_vars.Add(v)

var/list/item_down_icons = list()

item
	parent_type = /obj
	name = "Item"
	layer = 3.5
	var/material/material = /material
	var/displaysMaterial = 0
	var/weaponstats/weapon
	var/tmp/equipmentslot/slot

	var/canEquipTo = ""
	var/tmp/image/equip_image
	var/tmp/icon
		up_icon
		down_icon
	var/gender_separated_states = ""
	var/equip_layer = 99

	var/stack_size = 1
	var/max_stack_size = 1
	var/plural_name
	var/singular_name
	var/unit_weight
	var/custom_drop_sound

	var/label

	CanMoveTo(turf/B)
		for(var/atom/movable/M in B.contents)
			if(M.density || M.PreventsCrossing(src,get_dir(src,B)))
				return 0
		return 1

	New()
		. = ..()
		SetMaterial(material)
		if(!displaysMaterial)
			name = material.object_name
		GenerateEquipImage()
		if(!singular_name) singular_name = name
		if(!plural_name) plural_name = name
		if(world.time > 10)
			stack_size = 1
		if(!unit_weight)
			unit_weight = weight
			weight *= stack_size
		UpdateStacks()


	Del()
		if(istype(slot))
			var/mob/M = loc
			var/equipmentslot/itemslot = slot
			itemslot.Unequip(M)
			M.EquipmentChanged(itemslot)
		. = ..()
	Vanish()
		if(istype(slot))
			var/mob/M = loc
			var/equipmentslot/itemslot = slot
			itemslot.Unequip(M)
			M.EquipmentChanged(itemslot)
		. = ..()

	OperatedBy(mob/M)
		if(M.equipment)
			if(src.loc == M && max_stack_size > 1)
				var/item/I = Pop()
				I.Get(M)
				if(istype(loc,/item/container))
					var/item/container/C = loc
					C.UpdatePack(M)
			else
				if(istype(loc,/item/container))
					var/item/container/C = loc
					C.Remove(src,M)
					C.UpdatePack(M)
				var/equipmentslot/old = slot
				Get(M)
				if(old) M.EquipmentChanged(old)


	SetLight(r,i)
		..(r,i)
		if(slot)
			var/mob/M = loc
			M.EquipmentChanged(slot)

	proc
		GenerateEquipImage()
			up_icon = icon
			//world << "Icon: \icon[icon] UpIcon: \icon[up_icon]"
			equip_image = image(icon, icon_state = "equipped-mainhand", layer = equip_layer-100)
			if(type in item_down_icons)
				down_icon = item_down_icons[type]
			else
				down_icon = new()
				for(var/s in icon_states(icon))
					var/icon/I = icon(icon,s)
					I.Turn(90)
					I.Shift(SOUTH,8)
					down_icon.Insert(I,s)
				item_down_icons.Add(type)
				item_down_icons[type] = down_icon

		UpdateEquipOverlay(mob/human/H)
			if(!istype(H)) return
			H.overlays -= equip_image
			if(H.IsDown())
				equip_image.icon = down_icon
			else
				equip_image.icon = up_icon
			H.overlays += equip_image

		SetMaterial(mat)
			ASSERT(ispath(mat))
			if(istype(material,/material))
				name = material.object_name
			material = new mat(src)
			name = material.desc + " " + material.object_name

		Apply(mob/M, atom/A)
			if(A == src)
				UsedBy(M)
			else if(A.type == src.type && max_stack_size > 1)
				A:TransferStacks(1,src)
			else
				AppliedTo(M, A)
				A.AppliedBy(M, src)

		AppliedTo(mob/M, atom/A)

		ApplyAtRange(mob/M, atom/A)


		AttackWith(mob/M, atom/A)


		Get(mob/M)
			if(src.Move(M))
				M.Sound('Sounds/Inventory/Get.ogg')
				M.equipment.mainHandSlot.Equip(src,M)
				M.EquipmentChanged(M.equipment.mainHandSlot)

		GetSupport(mob/M)
			if(src.Move(M))
				M.Sound('Sounds/Inventory/Get.ogg')
				M.equipment.offHandSlot.Equip(src,M)
				M.EquipmentChanged(M.equipment.offHandSlot)

		Drop(mob/M, turf/T)
			if(src.Move(T))
				Sound(custom_drop_sound ? custom_drop_sound : 'Sounds/Inventory/Drop.ogg')
				var/equipmentslot/itemslot = slot
				itemslot.Unequip(M)
				M.EquipmentChanged(itemslot)

		CanEquipTo(txt)
			ASSERT(istext(txt))
			var/list/slots = dd_text2list(canEquipTo,", ")
			for(var/s in slots)
				if(s == txt) return 1
			return 0

		Equip(mob/mob, equipmentslot/slot)
			var/equipmentslot/oldslot = src.slot
			if(mob.equipment.CanEquip(slot, src))
				slot.Equip(src,mob)
				mob.EquipmentChanged(slot)
				mob.Sound('Sounds/Inventory/Equip.ogg')
				if(oldslot) mob.EquipmentChanged(oldslot)

		UsedBy(mob/M)

		ApplyBlood()
			icon_state = "blood"

		Consume()
			addStacks(-1)

		Pop()
			if(stack_size > 1)
				addStacks(-1)
				var/item/I = new src.type(loc)
				I.stack_size = 1
				I.weight = unit_weight
				I.CopyFromStack(src)
				I.UpdateStacks()
				return I
			else
				var/itemslot = slot
				slot.Unequip(loc)
				loc:EquipmentChanged(itemslot)
				return src

		TransferStacks(n, item/I)
			if(I.type == src.type)
				if(I.stack_size+n > I.max_stack_size)
					n = I.max_stack_size - I.stack_size

				if(stack_size < n)
					n = stack_size

				if(n <= 0) return

				I.addStacks(n)
				addStacks(-n)
				if(loc) loc:Sound('Sounds/Inventory/Get.ogg')

		addStacks(n)
			stack_size += n
			weight += unit_weight*n
			if(stack_size <= 0)
				world << "Deleted item with no stacks."
				del src
			else UpdateStacks()


		UpdateStacks()
			if(stack_size > 1)
				name = "[stack_size] [plural_name]"
				icon_state = "stack"
			else
				name = "[Article(singular_name)] [singular_name]"
				icon_state = ""

			if(label) name += " - [label]"

			/*var/mob/M = loc
			if(ismob(M) && slot)
				var/equipmentslot/itemslot = slot
				itemslot.Unequip(M)
				M.EquipmentChanged(itemslot)*/

		CopyFromStack(item/I)