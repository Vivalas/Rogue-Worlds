healthtracker
	var
		max_health = 100
		blunt_damage = 0
		piercing_damage = 0
		projectile_damage = 0
		toxic_damage = 0
		internal_damage = 0
		permanent_damage = 0

		mob/patient

	New(mob/M)
		patient = M
		Update()

	proc
		//Returns actual health (not HUD health).
		getHealth()
			return max_health - (blunt_damage + piercing_damage + projectile_damage + toxic_damage + internal_damage + permanent_damage)

		//Applies a specific damage type.
		applyDamage(dtype, amount)
			ASSERT(isnum(amount) && amount > 0)
			var/v = getDamageVariable(dtype)
			vars[v] += amount
			. = amount
			patient.HealthChanged()

		//Heals a specific damage type. Transferring damage to other types is handled within the healing item.
		healDamage(dtype,amount)
			ASSERT(isnum(amount) && amount > 0)
			var/v = getDamageVariable(dtype)
			if(vars[v] >= amount)
				vars[v] -= amount
				. = amount
			else
				. = vars[v]
				vars[v] = 0
			patient.HealthChanged()

		//Returns the variable name corresponding to a damage type.
		getDamageVariable(dtype)
			/*switch(dtype)
				if("Blunt")
					return "blunt_damage"
				if("Piercing")
					return "piercing_damage"
				if("Projectile")
					return "projectile_damage"
				if("Toxic")
					return "toxic_damage"
				if("Internal")
					return "internal_damage"
				if("Permanent")
					return "permanent_damage"
				else
					CRASH("Invalid damage type: "+dtype)*/
			var/variable_name = "[lowertext(dtype)]_damage"
			if(variable_name in vars)
				return variable_name
			else
				CRASH("Invalid damage type: "+dtype)

		Update()
			if(patient.GetStamina() < 100) patient.Stamina(-1)
			if(blunt_damage > 0) healDamage("Blunt",0.5)