item/construction
	icon_state = "stack"
	max_stack_size = 5
	stack_size = 5
	weight = 1
	bars
		name = "Bars"
		desc = "A long piece of material used for construction."
		singular_name = "Bar"
		icon = 'Icons/Items/Materials/IronBars.dmi'
		weight = 5
		weapon = new(damagetype = "Blunt", damage=15, to_hit = 5, exertion = 8, ko_damage = 25, block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)
		displaysMaterial = 1
		material = /material/iron
		custom_drop_sound = 'Sounds/Combat/BlockMetal1.ogg' //similar enough to be mistaken for clashing weapons.
		planks
			name = "Planks"
			singular_name = "Plank"
			icon = 'Icons/Items/Materials/Planks.dmi'
			weight = 3
			weapon = new(damagetype = "Blunt", damage=12, to_hit = 5, exertion = 5, ko_damage = 20, block_sounds = WOOD_BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS)
			material = /material/wood
			custom_drop_sound = null

		brass
			material = /material/brass
			weight = 4
			icon = 'Icons/Items/Materials/BrassBars.dmi'
			Apply(mob/M, atom/A)
				if(istype(A,/tile) || istype(A,/turf))
					var/item/I = M.equipment.GetSupportItem(/item/tool/wrench)
					if(I)
						var/tile/T = locate() in M.loc
						if(T.InverseConstruct(M, RAILING_CON, src, I, "a section of railing", /ship/railing, BAR_SND))
							var/ship/railing/R = locate() in M.loc
							if(R)
								if(M.loc != A.loc)
									R.dir = get_dir(M,A)
								else
									R.dir = M.dir
								R.UpdateRails()
						return
				return ..()
		gold
			material = /material/gold
			weight = 8
			icon = 'Icons/Items/Materials/GoldBars.dmi'
	sheets
		name = "Sheets"
		desc = "A flat piece of material used for construction."
		singular_name = "Sheet"
		icon = 'Icons/Items/Materials/IronSheet.dmi'
		displaysMaterial = 1
		material = /material/iron
		weight = 6
		weapon = new(damagetype = "Blunt", damage=15, to_hit = 2, exertion = 10, ko_damage = 25, block_sounds = BLOCK_SOUNDS, hit_sounds = BLUNT_SOUNDS, def_bonus = 10)
		brass
			icon = 'Icons/Items/Materials/BrassSheet.dmi'
			weight = 5
			material = /material/brass

		glass
			icon = 'Icons/Items/Materials/GlassSheet.dmi'
			weight = 6
			material = /material/glass

	sprockets
		name = "Sprockets"
		desc = "Mechanical parts to make things move."
		singular_name = "Sprocket"
		icon = 'Icons/Items/Materials/Sprocket.dmi'
		displaysMaterial = 1
		material = /material/gold
		weight = 1
		weapon = new(damagetype = "Piercing", damage=3, to_hit = 15, exertion = 2, def_bonus = -10, hit_sounds = SWORD_SOUNDS, hit_icon = 'Icons/Interface/CombatSlice.dmi')
