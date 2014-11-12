

var/list/priority_jobs = list(/job/captain, /job/cargo_officer, /job/mechanic, /job/doctor)
var/list/selectable_jobs = list()
var/job/passenger/passenger_job = new

proc/LoadJobs()
	var/load_jobs = typesof(/job) - /job - /job/passenger
	for(var/type in load_jobs)
		selectable_jobs += new type

proc/CreateJobPages(mob/M)
	var/pages_required = round(selectable_jobs.len/10)+1
	if(pages_required > 1)
		winset(M,"jobpage1.next","is-visible=true")
		for(var/n = 2, n <= pages_required, n++)
			winclone(M,"jobpage1","jobpage[n]")
			winset(M,"jobpage[n].pagenumber","text=\"[n]\"")
			winset(M,"jobpage[n].back","is-visible=true")
			if(n < pages_required) winset(M,"jobpage[n].next","is-visible=true")

	var/jobcount = 0
	for(var/job/J in selectable_jobs)
		jobcount++
		var/page = round(jobcount / 10)+1
		var/index = (jobcount % 10)

		world << "[jobcount] - [J.name] P[page] I[index]"

		//winset(M,"jobpage[page].sealicon[index]","image=[S.icon];is-visible=true")
		if(J.type in priority_jobs) winset(M,"jobpage[page].jobtitle[index]","background-color=[rgb(232,148,21)]")
		winset(M,"jobpage[page].jobtitle[index]","text=\"[J.name]\";is-visible=true")
		winset(M,"jobpage[page].jobdesc[index]","text=\"[J.desc]\";is-visible=true")


job
	var
		name = ""
		desc = "No Description"
		associated_skill = NOSKILLS
		key_access = ""
		max_assignable = 1 //absolute maximum
		current_assignable = 1
		assigned = 0
		scaling = 0 //increase possible jobs by this amount per 5 people

	proc
		Assign(mob/characterselect/M)
			assigned++
			M.Selected.job = src
			ready_players -= M

		Available()
			return assigned < current_assignable + scaling * active_player_count

		AssignInventory(mob/human/M)
			var/item/clothes/shirt/shirt = new(M)
			var/item/clothes/trousers/trousers = new(M)

			shirt.Equip(M,M.equipment.GetSlot("Shirt"))
			trousers.Equip(M,M.equipment.GetSlot("Trousers"))

	captain
		name = "Captain"
		associated_skill = LEADERSHIP
		//key_access = everything
		AssignInventory(mob/human/M)
			var/item/clothes/shirt/shirt = new(M)
			var/item/clothes/trousers/captain/trousers = new(M)
			var/item/clothes/jacket/captain/jacket = new(M)
			var/item/container/keyring/captain/keys = new(M)

			shirt.Equip(M,M.equipment.GetSlot("Shirt"))
			trousers.Equip(M,M.equipment.GetSlot("Trousers"))
			jacket.Equip(M,M.equipment.GetSlot("Jacket"))
			keys.Equip(M,M.equipment.GetSlot("Belt"))

	officer
		name = "First Officer"
		associated_skill = LEADERSHIP
		//key_access = everything
		AssignInventory(mob/human/M)
			var/item/clothes/shirt/shirt = new(M)
			var/item/clothes/trousers/captain/trousers = new(M)
			var/item/clothes/jacket/officer/jacket = new(M)

			shirt.Equip(M,M.equipment.GetSlot("Shirt"))
			trousers.Equip(M,M.equipment.GetSlot("Trousers"))
			jacket.Equip(M,M.equipment.GetSlot("Jacket"))

	security
		name = "Security Officer"
		associated_skill = COMBAT
		//5 - 1, 10 - 2, 15 - 3, 20 - 4, 25 - 5
		max_assignable = 5
		current_assignable = 1
		AssignInventory(mob/human/M)
			var/item/clothes/shirt/security/shirt = new(M)
			var/item/clothes/trousers/trousers = new(M)
			var/item/armor/armor = new(M)

			shirt.Equip(M,M.equipment.GetSlot("Shirt"))
			trousers.Equip(M,M.equipment.GetSlot("Trousers"))
			armor.Equip(M,M.equipment.GetSlot("Jacket"))

	mechanic
		name = "Ship Mechanic"
		associated_skill = MECHANICS
		//5 - 3, 10 - 4, 15 - 5, 20 - 6, 25 - 7
		max_assignable = 10
		current_assignable = 1
		AssignInventory(mob/human/M)
			var/item/clothes/shirt/mechanic/shirt = new(M)
			var/item/clothes/trousers/trousers = new(M)

			shirt.Equip(M,M.equipment.GetSlot("Shirt"))
			trousers.Equip(M,M.equipment.GetSlot("Trousers"))

	scientist
		name = "Scientist"
		associated_skill = SCIENCE
		//5 - 2, 10 - 3, 15 - 4, 20 - 5, 25 - 6
		max_assignable = 10
		current_assignable = 1

	doctor
		name = "Doctor"
		associated_skill = MEDICINE
		//5 - 2, 10 - 3, 15 - 4, 20 - 5, 25 - 6
		max_assignable = 8
		current_assignable = 1

	cargo_tech
		name = "Cargo Technician"
		associated_skill = LABOUR
		max_assignable = 8
		current_assignable = 1

	cargo_officer
		name = "Cargo Officer"
		associated_skill = LEADERSHIP

	locksmith
		name = "Locksmith"
		associated_skill = MECHANICS

	flight_attendant
		name = "Flight Attendant"
		associated_skill = NOSKILLS

	passenger
		name = "Passenger"
		associated_skill = NOSKILLS

proc/JobStartingArea(job/job)
	var/list/tiles = list()
	FindingMarkers:
		for(var/system/jobmarker/J)
			if(J.name == job.name)
				for(var/atom/movable/M in J.loc)
					if(M.PreventsPassing(0)) continue FindingMarkers
				tiles.Add(J.loc)
	return tiles

system/jobmarker
	icon = 'Icons/Debug/Marker.dmi'
	icon_state = "job"
	invisibility = 101

	captain
		name = "Captain"

	officer
		name = "First Officer"

	security
		name = "Security Officer"

	mechanic
		name = "Ship Mechanic"

	scientist
		name = "Scientist"

	doctor
		name = "Doctor"

	cargo_tech
		name = "Cargo Technician"

	cargo_officer
		name = "Cargo Officer"

	locksmith
		name = "Locksmith"

	flight_attendant
		name = "Flight Attendant"

	passenger
		name = "Passenger"