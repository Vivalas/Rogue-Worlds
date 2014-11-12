weaponstats
	var
		to_hit
		def_bonus
		damage
		ko_damage
		damagetype
		exertion
		range
		hit_sounds
		block_sounds
		hit_icon
		parry_tier

	New(damagetype = "Blunt", to_hit = 0, damage = 3, exertion = 2, range = 1, ko_damage = 0, def_bonus = 0, parry_tier = 3,
	 hit_sounds = list('Sounds/Combat/Punch1.ogg','Sounds/Combat/Punch2.ogg'), block_sounds = list('Sounds/Combat/BlockPunch.ogg'),
	 hit_icon = 'Icons/Interface/CombatStrike.dmi')
		src.damagetype = damagetype
		src.to_hit = to_hit
		src.damage = damage
		src.exertion = exertion
		src.range = range
		src.ko_damage = ko_damage
		src.def_bonus = def_bonus
		src.hit_sounds = hit_sounds
		src.block_sounds = block_sounds
		src.parry_tier = parry_tier
		src.hit_icon = hit_icon


	proc/GetHitSound()
		return pick(hit_sounds)
	proc/GetBlockSound()
		return pick(block_sounds)

var/weaponstats/default_weapon = new(damage = 5, ko_damage = 4, parry_tier = 0, def_bonus = -8)