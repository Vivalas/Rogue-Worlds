mob
	proc/Life()







mob/human/Life()
	if(dead) return
	var/archived_damage = damage()
	if(archived_damage > max_health + 40) Die()
	else if(archived_damage > max_health && !critical)
		viewers(src) << "<B>[src]</b>'s breathing becomes brief and shallow."
		critical = 1
		if(!is_down) Down(50)

	if(temp_damage > 2) temp_damage -= 2
	else temp_damage = 0

	if(recovery_damage > 0.05) recovery_damage -= 0.05
	else recovery_damage = 0

