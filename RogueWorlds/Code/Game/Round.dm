var/list/ready_players = list()
var/active_player_count = 0
var/round_started = 0

var/total_ports = 0
var/list/events = list()

proc/StartRound()
	world << "<b><big>Round Start</big></b>"
	round_started = 1
	AssignAllJobs()
	CreateAndMovePlayers()
	GeneratePorts()
	StartShip()
	//ChooseEvents()

proc/ReadyCheck()
	for(var/mob/characterselect/M)
		if(!(M in ready_players)) return 0
	return 1

mob/verb/DbgStartRound()
	StartRound()

proc/AssignAllJobs()

	/*
		Assign priority jobs until each has one player filling it.
		Random unassigned job: Assign to best player.
	*/
	var/list/assigned_players = ready_players.Copy()

	var/list/possible_jobs = selectable_jobs.Copy()
	for(var/j in priority_jobs)
		var/job/J = GetJob(j)
		AssignJob(J,true)
		if(!J.Available())
			possible_jobs -= J
	while(possible_jobs.len > 0 && ready_players.len > 0)
		var/job/J = pick(possible_jobs)
		AssignJob(J)
		if(!J.Available())
			possible_jobs -= J

	if(ready_players.len > 0)
		world.log << "Not enough jobs for players."
		world << "\red Not enough jobs for players."
		for(var/mob/characterselect/M in ready_players)
			passenger_job.Assign(M)

	ready_players = assigned_players

proc/CreateAndMovePlayers()
	for(var/mob/characterselect/M in ready_players)
		winshow(M,"charselect", 0)

		var/mob/human/H = new/mob/human(M.vars["Character[M.selected]"])
		H.client = M.client

		var/job/J = M.Selected.job
		J.AssignInventory(H)

		H << "<b>You are the [J.name]</b>"

		var/list/start_area = JobStartingArea(J)
		if(!start_area.len) continue

		var/turf/T = pick(start_area)
		H.Move(T)

proc/AssignJob(job/job, priority)
	var/list
		candidates
		first_candidates
		second_candidates
		third_candidates
	for(var/mob/characterselect/player in ready_players)
		if(player.Selected.job1 == job.name)
			if(!first_candidates) first_candidates = list()
			first_candidates += player
		else if(player.Selected.job2 == job.name)
			if(!second_candidates) second_candidates = list()
			second_candidates += player
		else if(player.Selected.job3 == job.name)
			if(!third_candidates) third_candidates = list()
			third_candidates += player

	if(first_candidates)
		candidates = first_candidates
		dbg("First candidates selected.")
	else if(second_candidates)
		candidates = second_candidates
		dbg("Second candidates selected.")
	else if(third_candidates)
		candidates = third_candidates
		dbg("Third candidates selected.")
	else
		if(priority)
			candidates = ready_players
			dbg("Any player selected.")
			if(!candidates.len)
				return
		else return

	var/mob/player = pick(candidates)
	job.Assign(player)

proc/GetJob(type)
	for(var/job/J in selectable_jobs)
		if(J.type == type) return J
	return null