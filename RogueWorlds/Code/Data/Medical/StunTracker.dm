stuntracker
	var
		list/stun_list = new
		list/ko_list = new
		is_stunned = 0
		is_down = 0
		is_dazed = 0
		stamina = 100

		can_fight = 1

		mob/patient

	New(mob/M)
		patient = M
	proc
		Daze(time = 10)
			patient.Sound('Sounds/Combat/Dizzy.ogg',0)
			is_dazed++
			spawn(time)
				is_dazed--
		//Stuns the player from a specified source for an amount of time, or 0 for indefinite stuns.
		Stun(source, time = 0)
			stun_list.Add(source)
			if(time > 0)
				scheduler.schedule(new/Event/timed_stun(src,source), time)
			is_stunned = 1
			patient.StunChanged()

		//Removes all stuns from a specified source.
		UnStun(source)
			stun_list.Remove(source)
			if(stun_list.len == 0)
				is_stunned = 0
			patient.StunChanged()

		//KOs the player from a specified source for an amount of time, or 0 for indefinite KOs.
		Down(source, time = 0)
			ko_list.Add(source)
			if(time > 0)
				scheduler.schedule(new/Event/timed_stun/timed_ko(src,source), time)
			is_down = 1
			patient.StunChanged()

		//Removes all KOs from a specified source.
		Up(source)
			ko_list.Remove(source)
			if(ko_list.len == 0)
				is_down = 0
			patient.StunChanged()

		//Returns true if the client can control this mob's movement in its current state.
		CanMove()
			return !(is_stunned || is_down)

		//Returns true if the client can click on objects in its current state.
		CanClick()
			return !(is_stunned || is_down)

		//Returns an icon state corresponding to the current stun state.
		GetStunState()
			if(is_down || is_stunned)
				return "down"
			else
				return ""

Event/timed_stun
	var/stuntracker/tracker
	var/source
	New(stuntracker/new_tracker, new_source)
		tracker = new_tracker
		source = new_source
	fire()
		tracker.UnStun(source)

Event/timed_stun/timed_ko
	fire()
		tracker.Up(source)