item/tool
	name = "Tool"
	weight = 5
	material = /material/iron
	crowbar
		name = "Crowbar"
		desc = "For prying things off other things."
		icon = 'Icons/Items/Tools/Crowbar.dmi'
		weight = 3
		weapon = new(damagetype = "Piercing", damage=8, to_hit = 8, block_sounds = BLOCK_SOUNDS, hit_sounds = STAB_SOUNDS, hit_icon = 'Icons/Interface/CombatStab.dmi')

	hammer
		name = "Hammer"
		desc = "For driving nails into things."
		icon = 'Icons/Items/Tools/Hammer.dmi'
		weapon = new(damagetype = "Blunt", damage=10, to_hit = 8, exertion = 3, ko_damage = 8, block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)

	screwdriver
		name = "Screwdriver"
		desc = "For twisting screws into things."
		icon = 'Icons/Items/Tools/Screwdriver.dmi'
		weight = 3
		weapon = new(damagetype = "Piercing", damage = 5, to_hit = 10, block_sounds = BLOCK_SOUNDS, hit_sounds = STAB_SOUNDS, hit_icon = 'Icons/Interface/CombatStab.dmi')

	wrench
		name = "Wrench"
		desc = "For twisting nuts onto bolts going through things."
		icon = 'Icons/Items/Tools/Wrench.dmi'
		weapon = new(damagetype = "Blunt", damage=6, to_hit = 10, ko_damage = 8, block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)

	extinguisher
		name = "Fire Extinguisher"
		desc = "Extinguishes fires. Point and shoot at the base of the flames. Not rated for use on magical fire."
		icon = 'Icons/Items/Tools/Extinguisher.dmi'
		weight = 8
		weapon = new(damagetype = "Blunt", damage=15, to_hit = 6, exertion = 6, ko_damage = 16, block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)

	lockpicks
		name = "Lockpicks"
		gender = PLURAL
		desc = "The tools of a thief and locksmith alike."
		icon = 'Icons/Items/Tools/Lockpicks.dmi'
		weight = 1