#define FLAME_BRIGHTNESS 4,1
ship/equipment/science
	spectroscope
		name = "Spectroscopic Lens"
		icon = 'Icons/Chemicals/Science/Spectroscope.dmi'
		desc = "This lens allows you to view the refraction of light through chemicals."
		AppliedBy(mob/M, item/chem_holder/H)
			if(istype(H))
				var/list/spectrum = base_matrix.Copy()
				for(var/v in spectrum)
					spectrum[v] = 0
					for(var/chemical/C in H.chemicals)
						spectrum[v] += C.CharacterValue(v)
				M << "[H.name] Spectroscope:"
				var/line = "<tt>|"
				for(var/i = 1 to spectrum.len)
					var/value = spectrum[spectrum[i]]
					value = max(0,min(value,100))
					var/color
					if(value <= 0) color = "000000"
				//	if(value < 20 && value > 0)
				//		color = hsl2rgb(i*(250/spectrum.len)+2,0,64+value,255)
					else
						color = hsl2rgb(i*(250/spectrum.len)+2,255,24+value*1.04,255)
					line += "<font color=#[color]><b>[sd_dec2base(i,26)]</b></font color> "
				line = copytext(line,1,length(line))
				line += "|</tt>"
				M << line
			else if(istype(H,/item/science/tube_rack))
				for(var/item/chem_holder/C in H)
					AppliedBy(M,C)
	still
		name = "Alembic"
		icon = 'Icons/Chemicals/Science/Still.dmi'
		desc = {"Useful for separating different states of matter.
		To use, operate the alembic to turn it on, then apply a flask. Apply another flask to catch the separated liquid and gases.
		The alembic can also be used the same way when off to separate only gases."}
		var/item/chem_holder/flask/flask
		var/on = 0
		AppliedBy(mob/M,item/chem_holder/flask/F)
			if(istype(F))
				if(!flask)
					flask = F
					var/equipmentslot/slot = F.slot
					slot.Unequip(M)
					M.EquipmentChanged(slot)
					F.Move(src)
					M.Sound('Sounds/Chemicals/PlaceFlask.ogg')
					if(on) icon_state = "onflask"
					else icon_state = "flask"
				else
					if(on) M.Sound('Sounds/Chemicals/Boil.ogg')
					else M.Sound('Sounds/Chemicals/Gas.ogg')
					for(var/chemical/C in flask.chemicals)
						if(lowertext(C.state) != "solid")
							if(on)
								flask.chemicals -= C
								F.chemicals += C
							else if(lowertext(C.state) == "gas")
								flask.chemicals -= C
								F.chemicals += C
					F.UpdateChemicals()
		OperatedBy(mob/M)
			if(flask)
				flask.UpdateChemicals()
				flask.Move(loc)
				flask = null
				icon_state = (on?"on":"")
				M.Sound('Sounds/Chemicals/PlaceFlask.ogg')
			else
				on = !on
				if(on) SetLight(FLAME_BRIGHTNESS)
				else SetLight(0,0)
				M.Sound('Sounds/Chemicals/Squeak.ogg')
				icon_state = (on?"on":"")
	centrifuge
		name = "Magnetic Separator"
		icon = 'Icons/Chemicals/Science/Centrifuge.dmi'
		desc = "This device separates magnetic chemicals from nonmagnetic chemicals. \
		Insert a test tube with the chemicals you want to separate, then apply any flask to catch the magnetic chemicals. \
		Unfortunately, the central slot only fits test tubes, and cannot accept flasks."
		var/item/chem_holder/flask/test_tube/tube

		AppliedBy(mob/M,item/chem_holder/flask/test_tube/T)
			if(istype(T) && !tube)
				tube = T
				var/slot = T.slot
				T.slot.Unequip(M)
				M.EquipmentChanged(slot)
				T.Move(src)
				icon_state = "tube"
				M.Sound('Sounds/Chemicals/PlaceFlask.ogg')
			else if(istype(T,/item/chem_holder/flask) && tube)
				M.Sound('Sounds/Chemicals/Magnet.ogg')
				for(var/chemical/C in tube.chemicals)
					if(C.Magnetism() > 0 || C.Conductivity() > 50)
						T.chemicals += C
						tube.chemicals -= C
				T.UpdateChemicals()

		OperatedBy(mob/M)
			if(tube)
				tube.UpdateChemicals()
				tube.Move(loc)
				tube = null
				icon_state = null
				M.Sound('Sounds/Chemicals/PlaceFlask.ogg')


	mixers
		var/operation = MAT_ADD
		var/sound
		AppliedBy(mob/M,item/chem_holder/H)
			if(istype(H))
				Display(M)
				H.MixContents(operation)
		proc/Display()

		bunsen
			name = "Bunsen Burner"
			desc = "Apply a flask to mix chemicals over the burner."
			icon = 'Icons/Chemicals/Science/Burner.dmi'
			Display(mob/M)
				if(icon_state != "on")
					icon_state = "on"
					M.Sound('Sounds/Chemicals/Squeak.ogg')
					SetLight(FLAME_BRIGHTNESS)
					sleep(1)
				M.Sound('Sounds/Chemicals/Burn.ogg')
				M.VisualMessage("[M] prepares chemicals on [src].")
				. = ..()
			OperatedBy(mob/M)
				M.Sound('Sounds/Chemicals/Squeak.ogg')
				if(icon_state != "on")
					icon_state = "on"
					SetLight(FLAME_BRIGHTNESS)
				else
					icon_state = null
					SetLight(0,0)

		electrolyzer
			name = "Electrolyser"
			desc = "Apply a flask to mix chemicals with the electrolyser."
			icon = 'Icons/Chemicals/Science/Electrolyzer.dmi'
			operation = MAT_MUL
			Display(mob/M)
				flick("on",src)
				M.Sound('Sounds/Chemicals/Zap.ogg')
				M.VisualMessage("[M] prepares chemicals using [src].")
				. = ..()

	dispensers
		name = "Dispenser"
		desc = "Apply a flask to dispense 5V of the labeled chemical."
		var/chemical = /chemical/antinine
		var/solid = 0
		icon = 'Icons/Chemicals/Science/Dispenser.dmi'
		AppliedBy(mob/M, item/chem_holder/flask/F)
			if(istype(F))
				var/chemical/C = new chemical(1)
				C.mass = 2 * C.Density()
				if(C.state == "Gas") M.Sound('Sounds/Chemicals/Gas.ogg')
				else if(C.state == "Liquid") M.Sound('Sounds/Chemicals/Pour.ogg')
				else if(C.state == "Solid") M.Sound('Sounds/Chemicals/Crunch.ogg')
				F.AddChemical(C)
				var/display = C.name
				if(C.r_name) display = C.r_name
				M.VisualMessage("[M] adds 2V of [display] to [F].")

		antinine
			name = "Dispenser - Antinine"
			icon_state = "antinine"
		galtinium
			name = "Dispenser - Galtinium"
			chemical = /chemical/galtinium
			icon_state = "galtinium"
		oshotium
			name = "Dispenser - Oshotium"
			chemical = /chemical/oshotium
			icon_state = "oshotium"
		norasper
			name = "Dispenser - Norasper"
			chemical = /chemical/norasper
			icon_state = "norasper"
		sarcanine
			name = "Dispenser - Sarcanine"
			icon_state = "sarcanine"
			chemical = /chemical/sarcanine
		lenakohnium
			name = "Dispenser - Lenakohnium"
			icon_state = "lenakohnium"
			chemical = /chemical/lenakohnium
		rakulum
			name = "Dispenser - Rakulum"
			icon_state = "rakulum"
			chemical = /chemical/rakulum
		acoustiril
			name = "Dispenser - Acoustiril"
			icon_state = "acoustiril"
			chemical = /chemical/acoustiril
		crysticite
			name = "Dispenser - Crysticite"
			icon_state = "crysticite"
			chemical = /chemical/crysticite
		heterogen
			name = "Dispenser - Heterogen"
			icon_state = "heterogen"
			chemical = /chemical/heterogen
		berinium
			name = "Dispenser - Berinium"
			icon_state = "berinium"
			chemical = /chemical/berinium
	fan
		name = "Ventilation Fan"
		desc = "Clears the air of harmful gases."
		icon = 'Icons/Chemicals/Science/Fan.dmi'
		New()
			ambient_sound = new(src,'Sounds/Structure/Fan.ogg',20,9)
			. = ..()
		MachineOperate()
			if(!icon_state)
				icon_state = "on"
				flick("slow",src)
				ambient_sound.Play()
				spawn IntakeLoop()
			else
				ambient_sound.Stop()
				icon_state = null
				flick("slow",src)

		proc/IntakeLoop()
			while(icon_state == "on")
				sleep(5)
				for(var/ship/gas/G in view(loc))
					G.fan = src

item/container/box
	name = "Supply Box"
	desc = "Contains things. What kind of things depend on what kind of box it is."
	icon = 'Icons/Items/Cargo/SupplyBox.dmi'
	var/label_state = ""
	UpdateStacks()
		var/prev_state = icon_state
		. = ..()
		icon_state = prev_state

item/container/box/tube_box
	icon_state = "tubes"
	contents = newlist(/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,
	/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,
	/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube,/item/chem_holder/flask/test_tube)
	label = "Test Tubes"

item/container/box/flask_box
	icon_state = "flasks"
	contents = newlist(/item/chem_holder/flask,/item/chem_holder/flask,/item/chem_holder/flask,/item/chem_holder/flask,
	/item/chem_holder/flask)
	label = "Flasks"