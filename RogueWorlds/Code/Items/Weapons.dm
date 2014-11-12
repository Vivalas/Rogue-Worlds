/*var/list
	blunt_sounds = list('Sounds/Combat/Blunt1.ogg','Sounds/Combat/Blunt2.ogg','Sounds/Combat/Blunt3.ogg','Sounds/Combat/Blunt4.ogg')
	stab_sounds = list('Sounds/Combat/Stab1.ogg','Sounds/Combat/Stab2.ogg','Sounds/Combat/Stab3.ogg')
	sword_sounds = list('Sounds/Combat/Stab1.ogg','Sounds/Combat/Stab2.ogg','Sounds/Combat/Stab3.ogg')
	tool_block_sounds = list('Sounds/Combat/BlockMetal1.ogg','Sounds/Combat/BlockMetal2.ogg','Sounds/Combat/BlockMetal3.ogg',
	'Sounds/Combat/BlockMetal4.ogg','Sounds/Combat/BlockSword1.ogg','Sounds/Combat/BlockSword2.ogg')*/

item/weapon
	sword
		name = "Longsword"
		desc = "Sharp and cutty."
		icon = 'Icons/Items/Weapons/Sabre.dmi'
		weight = 5
		weapon = new(damagetype = "Piercing", damage=14, to_hit = 12, exertion = 3, def_bonus = 2, hit_sounds = SWORD_SOUNDS,
		block_sounds = BLOCK_SOUNDS, hit_icon = 'Icons/Interface/CombatSlice.dmi')

	shield
		name = "Tower Shield"
		desc = "Big and blocky."
		icon = 'Icons/Items/Weapons/Shield.dmi'
		weight = 12
		weapon = new(damagetype = "Blunt", damage=6, to_hit = 14, exertion = 3, def_bonus = 5, ko_damage = 8, hit_sounds = BLUNT_SOUNDS,
		block_sounds = BLOCK_SOUNDS, hit_icon = 'Icons/Interface/CombatStrike.dmi')

	gun
		/*
		Revolver DPS: 20-8/0.8 = 15
		Rifle DPS: 15-4/1.2 = 9
		*/
		name = "Revolver"
		desc = "Big and shooty."
		icon = 'Icons/Items/Weapons/Revolver.dmi'
		weight = 3

		var
			item/ammo/ammo

			ammo_type = /item/ammo/revolver
			max_ammo = 6
			fire_delay = 16
			reload_time = 33
			range = 20
			two_handed = 0

			fire_sound = 'Sounds/Combat/RevolverShotCock.ogg'
			reload_sound = 'Sounds/Combat/RevolverReload.ogg'

			last_fired = 0
			is_reloading = 0

		AppliedBy(mob/M, item/I)
			if(istype(I,ammo_type))
				M.Sound(reload_sound,5)
				var/ammo_to_load = max_ammo
				if(ammo)
					ammo_to_load -= ammo.stack_size
				else
					ammo = I.Pop()
					ammo_to_load -= 1
				if(ammo_to_load)
					I.TransferStacks(ammo_to_load,ammo)
				dbg("Loaded ammo.")
				is_reloading = 1
				sleep(reload_time)
				is_reloading = 0

		proc/FireToTarget(mob/user, mob/M)
			if(!ammo || is_reloading) return
			var/delay = fire_delay
			if(user.HasCombatSkill()) delay /= 2
			if(last_fired > world.time - delay) return

			user.Sound(fire_sound,10)
			last_fired = world.time
			FireFromAmmo(user, M, ammo)
			ammo.Consume()

		rifle
			name = "Rifle"
			icon = 'Icons/Items/Weapons/Rifle.dmi'
			weight = 10
			ammo_type = /item/ammo/rifle
			max_ammo = 12
			fire_delay = 12
			reload_time = 40
			range = 25
			two_handed = 1

item/ammo
	name = "Ammo"
	var
		bullets_per_shot = 1
		spread = 12
		bullet_type = /bullet/revolver

	max_stack_size = 18
	stack_size = 18
	weight = 0.2

	revolver
		name = "Revolver Ammo"
		gender = PLURAL
		icon = 'Icons/Items/Weapons/RevolverAmmo.dmi'
		icon_state = "stack"

	rifle
		name = "Rifle Ammo"
		gender = PLURAL
		icon = 'Icons/Items/Weapons/RifleAmmo.dmi'
		icon_state = "stack"
		max_stack_size = 36
		stack_size = 36
		bullet_type = /bullet/rifle
		spread = 8

bullet
	parent_type = /obj/sd_px_projectile
	range = 1
	var/damage = 20
	var/list/checked_mobs = list()
	var/direction = 0
	New()
		. = ..()
		var/direction = arctan2(dx,dy) + PI
		if(direction < PI_OVER_4 || direction > PI+PI_OVER_2+PI_OVER_4)
			direction = EAST
		else if(direction < PI_OVER_2 + PI_OVER_4)
			direction = NORTH
		else if(direction < PI + PI_OVER_4)
			direction = WEST
		else
			direction = SOUTH

	CheckHit(turf/check)
		for(var/atom/movable/M in check)
			if(M == src || M == owner) continue
			if(ismob(M) && !(M in checked_mobs))
				var/mob/targ = M
				if(BulletCombat(owner,targ,src))
					return M
				checked_mobs += M
			else if(M.PreventsAccess(direction))
				return M
		return null

	Hit(atom/A)
		dbg("Bullet hit [A].")
		if(!ismob(A))
			CreateBulletHole(A)
		del src


	revolver
		speed = 32*20
		damage = 30
	rifle
		speed = 32*25
		damage = 20

proc/FireFromAmmo(mob/S, atom/T, item/ammo/A)
	var/spread = A.spread
	if(S.HasCombatSkill()) spread /= 2
	FireSpread(S, T, A.bullet_type, A.bullets_per_shot, -spread)

proc/CreateBulletHole(atom/A)
	var/image/I = image('Icons/Misc/BulletHole.dmi',pixel_x = rand(0,29), pixel_y = rand(0,29))
	A.overlays += I

proc/BulletCombat(mob/attack,mob/defense,bullet/bullet)
	dbg("Bullet Combat vs [defense]")
	var/block_chance = 20
	if(defense.HasCombatSkill())
		block_chance += 30 //Defender bonus is a bit higher, so noobs can't just EoS guards to death without good gear.
		dbg("Defense has Skill")
	//if(attack.HasCombatSkill())
	//	block_chance -= SKILL_BONUS
	//	dbg("Attack has Skill")

	if(defense.CombatIsDazed())
		block_chance -= DAZE_BONUS
		dbg("Defense is dazed.")
		//attack.VisualMessage("(-20 Dazed) \...")
	if(attack.CombatIsDazed())
		dbg("Attack is dazed.")
		block_chance += DAZE_BONUS
		//attack.VisualMessage("(+20 Dazed) \...")
	var/available_step = availableStepRand(defense)
	if(available_step == defense.loc)
		dbg("Can't dodge.")
		block_chance /= 4

	var/item/shield = GetShieldItem(defense)
	var/can_parry = istype(shield) && shield.weapon.parry_tier >= 3
	if(!can_parry)
		if(available_step == defense.loc)
			block_chance = 0
		else
			block_chance *= 0.75

	dbg("Final Chance: [block_chance]%")

	if(!defense.fight_target || defense.fight_target == SEARCHING) defense.fight_target = attack
	var/blocked = prob(block_chance)
	if(blocked)
		if((prob(75) && available_step != defense.loc) || !can_parry)
			defense.Stamina(8) //Dodging bullets takes work.
			defense.Move(available_step)
			defense.Sound(pick('Sounds/Combat/DodgeBullet1.ogg','Sounds/Combat/DodgeBullet2.ogg','Sounds/Combat/DodgeBullet3.ogg'),0)
		else
			defense.Stamina(20)
			defense.Sound(pick('Sounds/Combat/BlockMetal1.ogg','Sounds/Combat/BlockMetal2.ogg','Sounds/Combat/BlockMetal3.ogg','Sounds/Combat/BlockMetal4.ogg'),0)
			spawn(2) defense.Sound(pick('Sounds/Combat/Ricochet1.ogg','Sounds/Combat/Ricochet2.ogg','Sounds/Combat/Ricochet3.ogg','Sounds/Combat/Ricochet4.ogg'),0)
			spawn CombatImage('Icons/Interface/CombatBlock.dmi',defense)
			return 1
	else
		defense.Damage("Projectile",bullet.damage)
		if(!defense.GetHealthSave(-bullet.damage))
			defense.Down("Combat Injury",150)
			attack.fight_target = SEARCHING
			//attack_message += pick("(B) falls.","(B) can't fight on.","(B) goes down.")
			//print_combat = 1

		defense.Sound(pick(STAB_SOUNDS),0)
		spawn CombatImage('Icons/Interface/CombatStab.dmi',defense)
		return 1