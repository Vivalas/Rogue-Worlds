item/chem_holder/flask
	icon = 'Icons/Chemicals/Flasks/Flask.dmi'
	singular_name = "Flask"
	desc = "Holds chemicals. Has a 25V capacity."
	var
		liquid_icon = 'Icons/Chemicals/Flasks/Flask.dmi'
		gas_icon = 'Icons/Chemicals/Flasks/FlaskGas.dmi'
		volume = 25
	UpdateChemicals(consolidate)
		var/max_chem
		var/max_vol = 0
		for(var/chemical/C in chemicals)
			if(!C.mass)
				chemicals -= C
				continue
			if(consolidate)
			//	dbg("[C] absorbing...")
				for(var/chemical/X in chemicals)
					if(X == C) continue
					if(X.name == C.name)
						C.mass += X.mass
						//dbg("[X.mass] units")
						X.mass = 0
						chemicals -= X

			if(C.Volume() > max_vol)
				max_vol = C.Volume()
				max_chem = C
		GetIcon(max_chem)

	GetIcon(chemical/C)
		if(!C)
			icon_state = null
			name = singular_name
			return

		var/color = lowertext(C.color)

		if(C.state == "Gas") icon = gas_icon
		else icon = liquid_icon
		icon_state = color

		var/display = C.name
		if(C.r_name) display = C.r_name
		if(chemicals.len > 1) display += " Etc"
		name = "[display]"

	AppliedTo(mob/M,tile/T)
		. = ..()
		if(istype(T) && !T.density)
			var/splash = 0
			for(var/chemical/C in chemicals)
				if(C.state == "Liquid") splash |= 1
				if(C.state == "Gas") splash |= 2

			if(splash & 2) M.Sound('Sounds/Chemicals/Gas.ogg')
			if(splash & 1) M.Sound('Sounds/Chemicals/Pour.ogg')
			if(splash == 0) M.Sound('Sounds/Inventory/Drop.ogg')

			new/item/chem_holder(T.loc,chemicals)
			chemicals = list()
			UpdateChemicals()

	AppliedBy(mob/M, item/chem_holder/H)
		if(istype(H))
			var/splash = 0
			for(var/chemical/C in H.chemicals)
				if(C.state == "Liquid") splash |= 1
				if(C.state == "Gas") splash |= 2

			if(splash & 2) M.Sound('Sounds/Chemicals/Gas.ogg')
			if(splash & 1) M.Sound('Sounds/Chemicals/Pour.ogg')
			if(splash == 0) M.Sound('Sounds/Chemicals/Crunch.ogg')

			chemicals += H.chemicals
			if(H.type == /item/chem_holder)
				H.Vanish()
			else
				H.chemicals = list()
				H.UpdateChemicals()
			UpdateChemicals(1)
		. = ..()