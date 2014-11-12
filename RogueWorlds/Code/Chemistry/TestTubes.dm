item/chem_holder/flask/test_tube
	singular_name = "Test Tube"
	desc = "Holds chemicals. Has a 5V capacity."
	icon = 'Icons/Chemicals/Flasks/TestTube.dmi'
	liquid_icon = 'Icons/Chemicals/Flasks/TestTube.dmi'
	gas_icon = 'Icons/Chemicals/Flasks/TestTubeGas.dmi'
	volume = 5

item/science/tube_rack
	icon = 'Icons/Chemicals/Science/TubeRack.dmi'
	name = "Test Tube Rack"
	desc = "This rack can hold up to four test tubes, and can be used in the spectroscope."
	icon_state = "4"
	contents = newlist(/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,
	/item/chem_holder/flask/test_tube)

	UpdateStacks()
		. = ..()
		icon_state = "[contents.len]"

	OperatedBy(mob/M)
		if(loc == M)
			if(contents.len > 0)
				var/item/T = contents[1]
				T.Get(M)
				M.Sound('Sounds/Chemicals/PlaceFlask.ogg')
				UpdateStacks()
		else
			return ..()
	AppliedBy(mob/M,item/chem_holder/flask/test_tube/T)
		if(istype(T) && contents.len < 4)
			var/equipmentslot/slot = T.slot
			slot.Unequip(M)
			M.EquipmentChanged(slot)
			T.Move(src)
			M.Sound('Sounds/Chemicals/PlaceFlask.ogg')
			UpdateStacks()
		else
			. = ..()