mob/human
	icon = 'Icons/Creatures/Players/Male.dmi'
	desc = "A human being. Has two arms, two legs, a head and probably some hair."
	weight = 30
	move_delay = 1

	var/image/hair
	var/characterdata/data

	New(characterdata/data)
		. = ..()
		if(data && !isturf(data))
			src.data = data
			name = data.name
			gender = data.gender
		else
			data = new(gender)
			src.data = data
			data.name = name

		data.GenerateHumanIcon(src)
		overlays += hair
		equipment = new(src)
		//health = new(src)
		//stun = new(src)
		if(!loc) PlaceAtStart()
	//	InitScreen()

	Login()
		. = ..()
		SealChanged()

	Fall(turf/T)
		tiles_fallen++
		if(T)
			. = ..()
		else
			Move(locate(2,2,1))
	Land(turf/T)
		if(tiles_fallen > 0)
			Stun("Fall",20)
			tiles_fallen = 0

	HasCombatSkill()
		return data.HasSkill(COMBAT)
	HasMechanicsSkill()
		return data.HasSkill(MECHANICS)
	HasLabourSkill()
		return data.HasSkill(LABOUR)
	HasActiveSeal(sealtype)
		if(!sealtype)
			if(istype(data.seal,/seal/active))
				return data.seal:is_active
			else
				return 1
		if(istype(data.seal,sealtype))
			if(ispath(sealtype,/seal/active))
				return data.seal:is_active
			else
				return 1

	proc
		blunt(n)
			return Damage("Blunt",n)
		piercing(n)
			return Damage("Piercing",n)
		projectile(n)
			return Damage("Projectile",n)

		internal(n)
			return Damage("Internal",n)
		permanent(n)
			return Damage("Permanent",n)

		heal(dtype,n)
			return Healing(dtype,n)

		PlaceAtStart()
			var/list/possible_turfs = list()
			for(var/turf/T in locate(/area/start))
				for(var/atom/movable/M in T)
					if(M.PreventsPassing(0)) continue
				possible_turfs.Add(T)
			ASSERT(possible_turfs.len > 0)
			Move(pick(possible_turfs))

		SealChanged()
			if(!client) return
			if(data.seal)
				winset(src,"seal","image=[data.seal.icon]")
				var/active = istype(data.seal,/seal/active)
				if(!active)
					winset(src,"seal","background-color=#000022;is-flat=true;border=sunken")
				else if(data.seal:is_active)
					winset(src,"seal","background-color=#000022;is-flat=false;border=sunken")
				else if(!data.seal.Available(src))
					winset(src,"seal","background-color=#220000;is-flat=true;border=sunken")
				else
					winset(src,"seal","background-color=#000000;is-flat=false;border=none")