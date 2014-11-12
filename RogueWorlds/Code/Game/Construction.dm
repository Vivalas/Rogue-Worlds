var/construction/construction = new

construction
	var
		patch_txt = "{M} is patching up {src}..."
		construct_txt = "{M} is building {src}..."
		deconstruct_txt = "{M} is deconstructing {src}..."
		lock_txt = "{M} is attaching a lock to {src}..."
		lock_remove_txt = "{M} is removing a lock from {src}..."
		c_success_txt = "\green {Src} has been built."
		dc_success_txt = "\green {Src} has been taken down."
		p_success_txt = "\green {Src} has been patched up."
		failure_txt = "\red {M} was interrupted."
	proc
		sprintf(txt, name, obj)
			txt = dd_replacetext(txt,"{M}",name)
			txt = dd_replacetext(txt,"{src}",obj)
			txt = dd_replacetext(txt,"{Src}",Capitalize(obj))
			return txt

		Check(mob/M, basetime, item/tool/tool, item/material, sound)
			var/skill_mod = 1
			if(M.HasLabourSkill()) skill_mod = 0.5

			basetime *= skill_mod
			var/time = basetime
			while(time > 0)
				sleep(1)
				time--
				if(time % 10 == 0)
					M.Sound(sound)
				if(M.last_acted > world.time - (basetime - time) || M.last_moved > world.time - (basetime-time))
					dbg("Interrupted by new action.")
					return 0
				if(M.equipment.GetItem() != tool)
					dbg("Not carrying primary.")
					return 0
				if(material && M.equipment.GetSupportItem(material.type) == null)
					dbg("Not carrying secondary.")
					return 0

			return 1

		CheckMechanics(mob/M, basetime, item/tool/tool, item/material, sound)
			var/skill_mod = 1
			if(M.HasMechanicsSkill()) skill_mod = 0.5

			basetime *= skill_mod
			var/time = basetime
			while(time > 0)
				sleep(1)
				time--
				if(time % 10 == 0)
					M.Sound(sound)
				if(M.last_acted > world.time - (basetime - time) || M.last_moved > world.time - (basetime-time))
					dbg("Interrupted by new action.")
					return 0
				if(M.equipment.GetItem() != tool)
					dbg("Not carrying primary.")
					return 0
				if(material && M.equipment.GetSupportItem(material.type) == null)
					dbg("Not carrying secondary.")
					return 0

			return 1

atom/movable
	proc
		Construct(mob/M, basetime, item/tool/tool, item/material, structname, structure, sound)
			M.VisualMessage(construction.sprintf(construction.construct_txt, M.name, structname))

			if(construction.Check(M, basetime, tool, material, sound))
				M.VisualMessage(construction.sprintf(construction.c_success_txt, FirstWord(M.name), structname))
				new structure(loc)
				material.Consume()
				return 1
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))
				return 0

		InverseConstruct(mob/M, basetime, item/tool/tool, item/material, structname, structure, sound)
			M.VisualMessage(construction.sprintf(construction.construct_txt, M.name, structname))

			if(construction.Check(M, basetime, tool, material, sound))
				M.VisualMessage(construction.sprintf(construction.c_success_txt, FirstWord(M.name), structname))
				new structure(loc)
				tool.Consume()
				return 1
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))
				return 0

		Deconstruct(mob/M, basetime, item/tool/tool, structname, drop = null, sound)
			M.VisualMessage(construction.sprintf(construction.deconstruct_txt, M.name, structname))

			if(construction.Check(M, basetime, tool, null, sound))
				M.VisualMessage(construction.sprintf(construction.dc_success_txt, FirstWord(M.name), structname))
				var/item/I = new drop(loc)
				if(istype(I) && M.equipment.GetSupportItem() == null)
					I.GetSupport(M)
				Vanish()
				return 1
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))
				return 0

		Vanish()
			SetOpacity(0)
			loc = null