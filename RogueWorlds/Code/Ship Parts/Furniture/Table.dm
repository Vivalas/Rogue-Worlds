var/icon
	tablecornerse = icon('Icons/Ship/Furniture/Table.dmi',"cornerse")
	tablecornersw = icon('Icons/Ship/Furniture/Table.dmi',"cornersw")

proc/JoinTables()
	for(var/ship/table/T)
		T.AutoJoin()

ship/table
	icon = 'Icons/Ship/Furniture/Table.dmi'
	icon_state = "0"
	name = "Table"
	desc = "For keeping things within reach."
	layer = 3
	displaysMaterial = 1
	preventsPassingFromDir = 15
	material = /material/wood
	New()
		. = ..()
		if(round_started)
			spawn(1) AutoJoin()
	Del()
		joindir = 0
		for(var/turf/T in GetCardinals())
			for(var/ship/table/L in T)
				L.joindir &= ~(get_dir(T,src))
				L.icon_state = "[L.joindir]"
		. = ..()

	var/joindir = 0
	proc/AutoJoin()
		set background = 1
		joindir = 0
		//world << "Cleared all joins."
		for(var/turf/T in GetCardinals())
			for(var/ship/table/L in T)
				joindir |= get_dir(src,T)
				//world << "Joining in direction: [get_dir(src,T)]"
		icon_state = "[joindir]"
		//world << "Final icon: [joindir]"
		SpecialCorners()
	proc/SpecialCorners()
		var/turf/T
		var/ship/table/L
		if(joindir & SOUTH && joindir & EAST)
			T = get_step(src,SOUTHEAST)
			L = locate() in T
			if(!L)
				overlays += tablecornerse
		if(joindir & SOUTH && joindir & WEST)
			T = get_step(src,SOUTHWEST)
			L = locate() in T
			if(!L)
				overlays += tablecornersw