item/light/lantern
	name = "Lantern"
	desc = "A portable light source. Can be lit with any open flame."
	icon = 'Icons/Items/Lantern.dmi'
	icon_state = "unlit"
	weapon = new(damagetype = "Blunt", damage=15, to_hit = 6, exertion = 6, ko_damage = 16,
	block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)
	UsedBy(mob/M)
		if(src.loc == M)
			if(icon_state == "unlit" || icon_state == "blood")
				if(icon_state == "blood") icon_state = "bloodlit"
				else icon_state = "lit"
				SetLight(3,2)
			else
				if(icon_state == "bloodlit") icon_state = "blood"
				else icon_state = "unlit"
				SetLight(0,0)
		else
			. = ..()

	ApplyBlood()
		if(icon_state == "unlit")
			icon_state = "blood"
		else
			icon_state = "bloodlit"