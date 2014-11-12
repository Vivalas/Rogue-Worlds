/*

Mami hits Jade over the head with an ENORMOUS BASEBALL BAT, but Jade dodges!
Jade stabs her IMPROBABLY ELABORATE KATANA at Mami. Mami falls to the ground.
Mami swings her ENORMOUS BASEBALL BAT at Jade, but Jade blocks the attack with her IMPROBABLY ELABORATE KATANA.
Jade counterattacks with her IMPROBABLY ELABORATE KATANA. Mami is bleeding.

(A) = attacker
(B) = defender
(WEAPON) = a/an/her/his weapon/fist/foot/kick/punch
(SHIELD) = shield
(BP) = her/his
*/

#define STARTING_BLOCK_CHANCE 70
#define EOS_BONUS 30
#define SKILL_BONUS 15
#define BACKSTAB_BONUS 15
#define FLANK_BONUS 8
#define DAZE_BONUS 15
#define STAMINA_BONUS 10

var/list
	combat_opener_msg = list(
	"(A) opens with (WEAPON), making a sharp jab at (B)",
	"(A) swings (WEAPON) at (B) in a wide arc"
	)
	combat_attack_msg = list(
	"(A) hits (B) over the head with (WEAPON)",
	"(A) attacks with (WEAPON)",
	"(A) swings (WEAPON) at (B)",
	"(A) jabs (WEAPON) at (B)"
	)
	combat_counter_msg = list(
	"(A) counters with (WEAPON)",
	"(A) returns (B)'s attacks with (WEAPON)"
	)
	combat_dodge_msg = list(
	", but (B) gets out of the way just in time!",
	", which (B) nimbly dodges!",
	", but (B) dodges the attack!",
	", but (B) gets out of the way!",
	", but missed!",
	". (B) dodges the attack!"
	)
	combat_block_msg = list(
	", which is blocked by (B)'s (SHIELD).",
	". It clashes loudly against (B)'s (SHIELD).",
	", connecting with (B)'s (SHIELD).",
	", but (B) blocks it with (BP) (SHIELD)",
	". (B)'s (SHIELD) guards (BP) from the attack."
	)

mob/proc
	GetHealthSave(modifier = 0)
		return prob(GetHealth() + 15 + modifier)
	GetStaminaSave(modifier = 0)
		return prob((GetStamina())/2 + 50 + modifier)

	ToggleFightMode()
		//if(last_fight && last_fight > world.time - 80)
		//	return
		if(!CanFight())
			src << "\red You cannot fight any longer."
			FightModeFalse()
			return
		if(!fight_target)
			fight_target = SEARCHING
			FightModeTrue()
			src << "You fight!"
		else
			fight_target = NONE
			if(fight) ExitFight()
			FightModeFalse()
			src << "You don't fight!"


	EnterFight(mob/M)
		src << "<b>Fighting <font color=[GetTextColor(M)]>[M]</font color>!</b>"
		//src << "<b><i>[EvaluateCombat(src,M)]</i></b>"
		if(!fight && !M.fight)
			fight = new(M)
		else if(fight == M.fight)
			fight_target = M
			//UpdateFightOverlays()
			FightModeTrue()
			return
		else if(M.fight)
			fight = M.fight
		else
			M.fight = fight
			fight.AddCombatant(M)
			fight_target = M
			last_fight = world.time
			FightModeTrue()
			return
		fight.AddCombatant(src)
		fight_target = M
		FightModeTrue()
		last_fight = world.time

	ExitFight(force = 0)
		//dbg("[src] left the fight.")
		if(fight) fight.RemoveCombatant(src)
		if(force)
			fight_target = NONE
			FightModeFalse()
			//if(stun) stun.can_fight = 0
		last_fight = world.time
		//for(var/image/I in fight_overlays)
		//	if(client) client.images.Remove(I)
		//fight_overlays = null

	/*AddFightOverlay(mob/M)
		var/image/I = image('Icons/Interface/CombatTarget.dmi',M)
		if(fight_target == M) I.icon_state = "active"
		src << I
		if(!fight_overlays) fight_overlays = list()
		fight_overlays.Add(I)

	RemoveFightOverlay(mob/M)
		for(var/image/I in fight_overlays)
			if(I.loc == M)
				if(client) client.images.Remove(I)
				fight_overlays.Remove(I)

	UpdateFightOverlays()
		for(var/image/I in fight_overlays)
			if(fight_target == I.loc) I.icon_state = "active"
			else I.icon_state = ""*/


	FightModeTrue()
		if(client)
			winset(src, "default.FightMode", "background-color=#550000;is-checked=true")
	FightModeFalse()
		if(client)
			winset(src, "default.FightMode", "background-color=#000000;is-checked=false")

	CanFight()
		if(can_fight && CanClick())
			return 1
		else
			return 0

	//Includes combat movement and tactical skills.
	FightTactic()
		if(last_fight_tactic && last_fight_tactic > world.time - 40)
			last_fight_tactic = world.time
			return 1
		else
			return 0

mob/verb/FightMode()
	ToggleFightMode()


mob/var/tmp
	fight/fight
	mob/fight_target
	last_fight = 0
	last_fight_tactic = 0
	//list/fight_overlays

proc/GetWeapon(mob/M)
	if(M.equipment)
		var/item/I = M.equipment.GetItem()
		if(I && I.weapon)
			return I.weapon
	return default_weapon

proc/GetShieldItem(mob/M)
	if(M.equipment)
		var/item/W = M.equipment.GetItem()
		var/item/S = M.equipment.GetSupportItem()
		if(W && S && W.weapon && S.weapon)
			if(W.weapon.def_bonus > S.weapon.def_bonus) return W
		else
			if(W && W.weapon) return W
			if(S && S.weapon) return S
	return default_weapon

proc/GetDefense(mob/M)
	var/bonus = 0
	if(M.equipment)
		var/item/I = M.equipment.GetItem()
		var/apply_bonus = 0
		if(I && I.weapon)
			bonus += I.weapon.def_bonus
			apply_bonus = 1
		I = M.equipment.GetSupportItem()
		if(I && I.weapon)
			bonus += I.weapon.def_bonus
			apply_bonus = 1
		I = M.equipment.GetArmor()
		if(I && I.weapon)
			bonus += I.weapon.def_bonus
			apply_bonus = 1
		if(apply_bonus) return bonus
		else return default_weapon.def_bonus
	else
		return default_weapon.def_bonus

fight
	var/list/combatants = list()
	var/next = 1
	var/combo = 0
	var/opened = 0

	New(mob/fighter)
		combatants.Add(fighter)
		spawn(1) NextTurn()

	Del()
		for(var/mob/C in combatants)
			C.ExitFight()
		return ..()

	proc/NextTurn(n=5)
		ASSERT(combatants.len)
		if(n == 0)
			dbg("Over recursion with combatants:")
			for(var/mob/M in combatants)
				dbg("[M]")
			del src
			return
		var/mob/attack = combatants[next]
		if(!attack.fight_target || attack.fight_target == SEARCHING)
			//fighter was unprepared, probably a victim of a surprise attack
			NextFighter()
			dbg("[attack] has no target.")
			return .(n-1)

		var/mob/defense = attack.fight_target


			//def_name = "<font color=[GetTextColor(defense)]>[defense]</font color>"
		var/print_combat = 0
		var/weaponstats/weapon = GetWeapon(attack)
		var/item/S = GetShieldItem(defense)
		var/weaponstats/shield = (S != default_weapon) ? (S.weapon) : (S)

		var
			weapon_name = pick("punch","kick","fist","foot")
			shield_name = pick("bare hands","forearm","shin","hand")
		var/item/W
		if(attack.equipment)
			W = attack.equipment.GetItem()
			if(W) weapon_name = W.singular_name

		if(S != default_weapon) shield_name = S.singular_name

		if(prob(50)) weapon_name = lowertext(Article(weapon_name)) + " " + weapon_name
		else weapon_name = (attack.gender==MALE?"his ":"her ") + weapon_name

		var/block_chance = STARTING_BLOCK_CHANCE //+ is in favor of the defender.

		var
			attack_message = ""
			att_name = "<font color=[GetTextColor(attack)]><b>[FirstWord(attack.name)]</b></font color>"
			def_name = "<font color=[GetTextColor(defense)]><b>[FirstWord(defense.name)]</b></font color>"

			surprised = ""
			flank = ""
			hit = 0

		if(istype(W,/item/weapon/gun))
			var/item/weapon/gun/G = W
			G.FireToTarget(attack,defense)
		if(1)
		//else
			if(get_dist(attack,defense) > weapon.range || !attack.CanFight()) //Skipped
				NextFighter()
				dbg("[attack] is out of range.")
				return .(n-1)

			if(!opened)
				attack_message = pick(combat_opener_msg + combat_attack_msg)
				att_name = "<font color=[GetTextColor(attack)]><b>[attack.name]</b></font color>"
				def_name = "<font color=[GetTextColor(defense)]><b>[defense.name]</b></font color>"
				opened = 1
				print_combat = 1
			else
				attack_message = pick(combat_counter_msg + combat_attack_msg)
				att_name = "<font color=[GetTextColor(attack)]><b>[attack.name]</b></font color>"
				def_name = "<font color=[GetTextColor(defense)]><b>[defense.name]</b></font color>"
				print_combat = 1
				//attack.VisualMessage("<font color=[GetTextColor(attack)]>[att_name]'s attack! \...")

			if(!defense.fight_target)
				//attack.VisualMessage("(-20 Major EoS) \...")
				// -= EOS_BONUS //ridiculous attack bonus because the defender didn't even have attack mode on.
				defense.CombatDaze(50)
				defense.fight_target = attack
				surprised = "a greatly surprised"
			else if(defense.fight_target == SEARCHING)
				defense.fight_target = attack
			else
				//Calculating the difference in angle between where defender is "facing" (assumed to be toward their target) and where attacker is.
				var
					dx_to_targ = defense.fight_target.x - defense.x
					dy_to_targ = defense.fight_target.y - defense.y
					dx_to_me = attack.x - defense.x
					dy_to_me = attack.y - defense.y

					rel_angle = arctan2(dx_to_targ,dy_to_targ) - arctan2(dx_to_me,dy_to_me)

				if(rel_angle > PI_OVER_2 + PI_OVER_4) //Rear attack
					attack.VisualMessage("(-10 Backstab) \...")
					block_chance -= BACKSTAB_BONUS
					flank = pick("from the back", "in the back", "from behind")
				else if(rel_angle > PI_OVER_4) //Flank attack
					attack.VisualMessage("(-5 Flanking) \...")
					block_chance -= FLANK_BONUS
					flank = pick("from the side", "in the side", "in the flank")

			if(surprised)
				attack_message = dd_replacetext(attack_message, "(B)", "[surprised] (B)")
			if(flank)
				attack_message += " [flank]"

			if(defense.HasCombatSkill())
				block_chance += SKILL_BONUS //Defender bonus is a bit higher, so noobs can't just EoS guards to death without good gear.
				//attack.VisualMessage("(+15 Defender Skill) \...")
			if(attack.HasCombatSkill())
				block_chance -= SKILL_BONUS
				//attack.VisualMessage("(-15 Attacker Skill) \...")

			if(defense.CombatIsDazed())
				block_chance -= DAZE_BONUS
				//attack.VisualMessage("(-20 Dazed) \...")
			if(attack.CombatIsDazed())
				block_chance += DAZE_BONUS
				//attack.VisualMessage("(+20 Dazed) \...")

			var/defbonus = GetDefense(defense)
			block_chance += defbonus//This is typically large, as it includes shields or armor.
			block_chance -= weapon.to_hit

			block_chance += (defense.GetStamina()/100)*STAMINA_BONUS
			block_chance -= (attack.GetStamina()/100)*STAMINA_BONUS
			//dbg("Defense Value: +[defbonus] / Attack Value: [(weapon.to_hit>0?"-":"+")][weapon.to_hit]")

			//dbg("Finally rolling block chance at [block_chance]%")
			//attack.VisualMessage("[block_chance]%</font color>")

			var/blocked = prob(block_chance)
			if(blocked && defense.CanFight())  //make sure the defender is actually conscious, too bad if you have armor, the attacker
											   //could just go around the armor anyways if you are knocked out
				var/can_parry = weapon.parry_tier <= shield.parry_tier
				if((!can_parry && prob(95)) || prob(40))
					//defense.VisualMessage("The attack was dodged.")
					attack_message += pick(combat_dodge_msg)
					attack.Stamina(weapon.exertion)
					var/former_loc = defense.loc
					defense.Move(availableStepRand(defense))
					if(get_dist(attack,defense) > 1)
						attack.Move(former_loc)
					defense.Sound(pick('Sounds/Combat/Miss1.ogg','Sounds/Combat/Miss2.ogg','Sounds/Combat/Miss3.ogg','Sounds/Combat/Miss4.ogg'),0)
					combo++
				else
					//defense.VisualMessage("The attack was blocked.")
					attack_message += pick(combat_block_msg)
					attack.Stamina(weapon.exertion)
					defense.Sound(shield.GetBlockSound(),0)
					spawn CombatImage('Icons/Interface/CombatBlock.dmi',defense)
					combo++
			else
				//defense.VisualMessage("\red The attack hit.")
				hit = 1
				if(W)
					W.icon_state = "blood"
				attack_message += ". "
				defense.Damage(weapon.damagetype,weapon.damage)
				if(!defense.GetHealthSave() && defense.CanFight())
					defense.Down("Combat Injury",150)
					attack.fight_target = SEARCHING
					attack_message += pick("(B) falls.","(B) can't fight on.","(B) goes down.")
					print_combat = 1
					//defense.VisualMessage("<font color=[GetTextColor(defense)]>[defense] goes down!</font color>")
				defense.Stamina(weapon.ko_damage)
				if(!defense.GetStaminaSave()  && defense.CanFight())
					if(defense.GetStamina() < 25 || defense.CombatIsDazed())
						defense.Down("Combat KO",150)
						attack.fight_target = SEARCHING
						attack_message += pick("(B) is knocked out.","(B) blacks out.","(B) goes down.")
						print_combat = 1
					else
						defense.CombatDaze(50)
						attack_message += "(B) is dazed."
					//defense.VisualMessage("<font color=[GetTextColor(defense)]>[defense] is dazed!</font color>")
				defense.Sound(weapon.GetHitSound(),2)
				spawn CombatImage(weapon.hit_icon,defense)
				combo += 2

		//dbg("Combat turn over.")

		if(print_combat)

			attack_message = dd_replacetext(attack_message, "(A)", att_name)
			attack_message = dd_replacetext(attack_message, "(B)", def_name)
			attack_message = dd_replacetext(attack_message, "(BP)", defense.gender==MALE?"his":"her")
			attack_message = dd_replacetext(attack_message, "(WEAPON)", weapon_name)
			attack_message = dd_replacetext(attack_message, "(SHIELD)", shield_name)

			attack_message += " ([100-block_chance]%)"

			defense.VisualMessage("<font color=[(hit)?("#FF0000"):("#CC0000")]><small>[attack_message]</small></font color>")

		NextFighter()
		//dbg("Next fighter: [combatants[next]]")
		if(prob(20*combo))
			combo = 0
			spawn(rand(8,20)) .(5)
		else
			spawn(rand(1,6)) .(5)
		//dbg("Rescheduled.")

	proc/NextFighter()
		next++
		if(next > combatants.len) next = 1

	proc/AddCombatant(mob/M)
		//for(var/mob/C in combatants)
			//C.AddFightOverlay(M)
		combatants.Insert(next+1,M) //Insert the new combatant after this one, so that they enter the fight quickly.

	proc/RemoveCombatant(mob/M)
		for(var/mob/C in combatants)
			if(C.fight_target == M)
				C.fight_target = SEARCHING
				dbg("Removed [C]'s target.")
		var/m_index = combatants.Find(M)
		//Keep turn order, otherwise someone's turn could be skipped when a previous player leaves the fight.
		if(next > m_index)
			next--
		combatants.Cut(m_index,m_index+1)
		if(combatants.len <= 1)
			del src

proc/EvaluateCombat(mob/A, mob/D)
	var/skill = A.HasCombatSkill()
	var/weaponstats/weapon = GetWeapon(A)
	var/weaponstats/dweapon = GetWeapon(D)
	var/diff = -(BlockChance(A,D) + dweapon.damage*2.5) + (BlockChance(D,A) + weapon.damage*2.5)

	if(!skill)
		var/msg = ""
		if(!D.fight_target)
			msg += "You have the element of surprise. "

		var/advantage = "no"
		if(weapon.to_hit >= 15)
			advantage = "a great"
		else if(weapon.to_hit >= 8)
			advantage = "a decent"
		else if(weapon.to_hit >= 4)
			advantage = "a slight"
		msg += "Your weapon gives [advantage] advantage.\n"

		if(diff > 20)
			msg += "You will likely win against [D]."
		else if(diff > 10)
			msg += "You have a slight advantage against [D]."
		else if(diff < -20)
			msg += "You will likely lose against [D]."
		else if(diff < -10)
			msg += "You have a slight disadvantage against [D]."
		else
			msg += "You and [D] seem evenly matched."
		return msg
	else
		var/msg = ""
		if(diff > 0)
			msg = "You have a [diff]% advantage against [D].\n"
		else
			msg = "You have a [diff]% disadvantage against [D].\n"

		if(D.HasCombatSkill())
			msg += "[D] appears trained in combat. "

		msg += "[D]'s weapon has a [dweapon.to_hit]% hit advantage and does [dweapon.damage]% [lowertext(dweapon.damagetype)] damage.\n"
		if(!D.fight_target)
			msg += "You have the element of surprise. "
		msg += "Your weapon has a [weapon.to_hit]% hit advantage and does [weapon.damage]% [lowertext(weapon.damagetype)] damage.\n"

		var/percent_chance = 115 - D.GetHealth() + weapon.damage
		msg += "If you hit on the first strike, you have a [percent_chance]% chance of a one-hit defeat."
		return msg

proc/BlockChance(mob/A, mob/D)
	var/block_chance = STARTING_BLOCK_CHANCE //+ is in favor of the defender.

	if(D.HasCombatSkill())
		block_chance += SKILL_BONUS
	if(A.HasCombatSkill())
		block_chance -= SKILL_BONUS

	var/weaponstats/weapon = GetWeapon(A)

	block_chance += GetDefense(D)
	block_chance -= weapon.to_hit

	return block_chance

proc/CombatImage(icon, targ)
	var/time = 0
	var/image/I = image(icon,targ,layer=101)
	world << I
	while(time < 5)
		sleep(1)
		time++
		I.icon_state = "[time]"
	del I