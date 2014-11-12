item/chem_holder
	desc = "A pile of chemicals."
	icon = 'Icons/Chemicals/Solids.dmi'
	icon_state = "poer"
	var/list/chemicals = list()
	var/is_liquid = 0
	var/created
	New(newLoc,newChemicals)
		. = ..()
		if(newChemicals) chemicals = newChemicals
		created = world.time
		UpdateChemicals()
	UpdateStacks()
		return
	Get(mob/M)
		if(type == /item/chem_holder)
			if(is_liquid)
				M.Sound('Sounds/Chemicals/Dunk.ogg')
				M.VisualMessage("[src] slips through [M]'s fingers.")
				return
		. = ..()

	proc
		AddChemical(chemical/X)
			for(var/chemical/C in chemicals)
				if(C.name == X.name)
					C.mass += X.mass
					X = null
			if(X) chemicals += X
			UpdateChemicals()
		RemoveChemical(chemical/X,qty)
			if(!qty)
				chemicals -= X
				return X
			else
				return X.SplitVolume(qty)
			UpdateChemicals()
		UpdateChemicals(consolidate)
			var/max_chem
			var/max_vol = 0
			is_liquid = 0
			var/list/gases
			if(chemicals.len <= 0) return Vanish()
			for(var/chemical/C in chemicals)
				if(C.state == "Liquid")
					is_liquid = 1
				if(C.state == "Gas")
					if(!gases) gases = list()
					gases += C
					chemicals -= C
					continue
				if(!C.mass)
					chemicals -= C
					continue
				if(C.state == "Liquid") //Evaporation n all that shit
					if(created < world.time - (200 + C.Density()*100))
						chemicals -= C
						continue
				if(consolidate)
					dbg("Combining [C]")
					for(var/chemical/X in chemicals)
						if(X.name == C.name)
							C.mass += X.mass
							chemicals -= X
							dbg("Absorbed [X.mass]u")
				if(C.Volume() > max_vol)
					max_vol = C.Volume()
					max_chem = C
			if(gases)
				Sound('Sounds/Chemicals/Gas.ogg')
				for(var/chemical/gas in gases)
					PlaceGas(loc,gas)
			if(chemicals.len <= 0)
				dbg("Holder is empty.")
				Vanish()
				return
			GetIcon(max_chem)

		GetIcon(chemical/C)
			if(!C)
				icon = 'Icons/Chemicals/Solids.dmi'
				icon_state = "poer"
				return
			var/icon/Cicon
			var/icon/Aicon

			var/appearance = lowertext(C.appearance)
			var/color = lowertext(C.color)

			if(!is_liquid) Aicon = new('Icons/Chemicals/Solids.dmi',appearance)
			else Aicon = new('Icons/Chemicals/Liquids.dmi',pick("1","2","3"))

			Cicon = new('Icons/Chemicals/Colors.dmi',color)
			Aicon.Blend(Cicon,ICON_ADD)
			icon = Aicon
			var/display = C.name
			if(C.r_name) display = C.r_name
			if(chemicals.len > 1)
				name = "Chemicals ([display])"
			else
				name = display

		MixContents(operation = MAT_ADD)
			if(chemicals.len <= 1) return
			dbg("Mixing chemicals.")
			var/offset = 0
			var/list/reactants = list()
			var/list/nonreactants = list()
			for(var/chemical/C in chemicals)
				var/cat = C.Catalysis()
				if(cat != 0)
					nonreactants += C
					if(abs(cat) > abs(offset))
						offset = cat
					dbg("[C]: Catalyst")
				else if(C.Corruption() > 80)
					nonreactants += C
					dbg("[C]: Corrupted")
				else
					reactants += C
					dbg("[C]: Reactant")

			offset = max(-3,min(3,offset))

			chemicals = list()

			while(reactants.len > 1)
				var/chemical/A = reactants[1]
				var/chemical/B = reactants[2]
				dbg("Mixing [A] and [B].")
				var/chemical/C = MixChemicals(A,B,operation,offset)
				reactants.Cut(1,3)
				chemicals += C
				dbg("Result: [C]")
			if(reactants.len == 1 && chemicals.len >= 1)
				dbg("Mixing [reactants[1]] and [chemicals[1]].")
				var/chemical/C = MixChemicals(reactants[1],chemicals[1],operation,offset)
				dbg("Result: [C]")
				chemicals.Cut(1,2)
				chemicals += C
			else if(reactants.len)
				chemicals += reactants
			chemicals += nonreactants
			UpdateChemicals(1)

	UsedBy(mob/M)
		var/window = ""
		for(var/chemical/C in chemicals)
			window += C.DebugWindow()
		M << browse(window,"window=chem")
		M << "Total Chemicals: [chemicals.len]"
		for(var/datum/C in chemicals)
			if(!istype(C,/chemical))
				M << " - [C.type]"