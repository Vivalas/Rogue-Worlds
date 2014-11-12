mob/var/skin_damage = 0     //Done by blunt instruments, and a component of burns. Requires bandaging.
mob/var/slash_damage = 0    //Done by swords and other sharp things. A component of shrapnel. Requires treatment and stitches.
mob/var/shrapnel_damage = 0 //Done by embedded objects such as bullets. Requires pulling out.
mob/var/chem_damage = 0     //Done by chemical burns and poisons. Requires antitoxin.

mob/var/recovery_damage = 0 //A long lasting form of damage occurring after treatment of serious injury. Goes away over time.
mob/var/temp_damage = 0     //Goes away over a far shorter time.

mob/var/stun_time = 0    //Seconds stunned for.
mob/var/ko_time = 0      //Seconds KO'd for.
mob/var/dead = 0     //Set when people are killed, which results in death.
mob/var/critical = 0
#define MAX_HEALTH  100
#define HUD_LAYER 100
mob/var/archived_damage
mob/var/obj/display/health_meter/health_meter

var/matrix/dead_matrix

mob/proc/brute(amt)
	skin_damage += amt

mob/proc/slash(amt)
	slash_damage += amt

mob/proc/shrapnel(amt)
	shrapnel_damage += amt

mob/proc/chem(amt)
	chem_damage += amt

mob/proc/ko(n)
	ko_time = max(ko_time,n)
	if(ko_time)
		transform = turn(src.transform,90)
		Sound('Sounds/Combat/Collapse.ogg')
		view(src) << "<b>[src]</b> is unconscious!"

mob/proc/stun(n)
	stun_time = max(stun_time, n)
	if(stun_time)
		view(src) << "<b>[src]</b> is stunned!"

mob/proc/damage()
	return skin_damage + slash_damage + shrapnel_damage + chem_damage + recovery_damage + temp_damage

mob/proc/GetHealth()
	return MAX_HEALTH - damage()
mob/IsStunned()
	return stun_time > 0 || ko_time > 0 || dead

mob/proc/Life()
	if(dead) return
	archived_damage = damage()
	if(archived_damage > MAX_HEALTH + 40) Die()
	else if(archived_damage > MAX_HEALTH && !critical)
		critical = 1
		ko(20)

	if(temp_damage > 2) temp_damage -= 2
	else temp_damage = 0

	if(recovery_damage > 0.05) recovery_damage -= 0.05
	else recovery_damage = 0

	if(stun_time) stun_time -= 0.5
	if(ko_time)
	//	sight |= BLIND
		ko_time -= 0.5
		if(!ko_time && !dead)
			transform = new/matrix
		//	sight &= ~BLIND
mob/proc/Die()
	view(src) << "<b>[src]</b> dies!"
	if(!ko_time)
		transform = turn(src.transform,90)
		Sound('Sounds/Combat/Collapse.ogg')
	dead = 1

mob/human/Life()
	. = ..()
	if(critical) move_delay = 6
	else if(archived_damage > MAX_HEALTH*0.6) move_delay = 4
	else move_delay = 2

