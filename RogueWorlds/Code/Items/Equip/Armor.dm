item/armor
	icon = 'Icons/Items/Clothes/Armor.dmi'
	name = "Armor"
	desc = "Armor which protects from enemy attacks."

	material = /material/iron
	displaysMaterial = 0
	canEquipTo = "Jacket"
	gender_separated_states = "Jacket"
	equip_layer = 2
	weapon = new(damagetype = "Blunt", damage=6, to_hit = 5, exertion = 3, def_bonus = 10, ko_damage = 8, hit_sounds = BLUNT_SOUNDS,
		block_sounds = BLOCK_SOUNDS, hit_icon = 'Icons/Interface/CombatStrike.dmi')