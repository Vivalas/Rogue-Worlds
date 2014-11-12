item/healing
	sutures
		name = "Sutures"
		singular_name = "Suture"
		icon = 'Icons/Items/Medical/Sutures.dmi'
		max_stack_size = 5
		stack_size = 5
		weight = 1
		weapon = new(damagetype = "Piercing", damage = 8, to_hit = 8, def_bonus = -10, hit_sounds = STAB_SOUNDS)
		AppliedTo(mob/M,atom/A)
			if(ismob(A))
				var/mob/O = A
				var/healing_done = O.Healing("Piercing",20)
				if(healing_done)
					O.Damage("Blunt",healing_done/2)
					if(O == M)
						M.VisualMessage("<font color=#00AA00>[M.DisplayName()] applied a suture to [PosPronoun(M)] wounds.</font color>")
					else
						M.VisualMessage("<font color=#00AA00>[M.DisplayName()] applied a suture to [O.DisplayName()]'s wounds.</font color>")
					Consume()
			else
				. = ..()

	tweezers
		name = "Tweezers"
		gender = PLURAL
		icon = 'Icons/Items/Medical/Tweezers.dmi'
		weight = 1
		weapon = new(damagetype = "Piercing", damage = 8, to_hit = 8, def_bonus = -10, hit_sounds = STAB_SOUNDS)
		AppliedTo(mob/M,atom/A)
			if(ismob(A))
				var/mob/O = A
				var/healing_done = O.Healing("Projectile",20)
				if(healing_done)
					O.Damage("Piercing",healing_done*0.75)
					if(O == M)
						M.VisualMessage("<font color=#00AA00>[M.DisplayName()] removed foreign objects from [PosPronoun(M)] body.</font color>")
					else
						M.VisualMessage("<font color=#00AA00>[M.DisplayName()] removed foreign objects from [O.DisplayName()]'s body.</font color>")
			else
				. = ..()