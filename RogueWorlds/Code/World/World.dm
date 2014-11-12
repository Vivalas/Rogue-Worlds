world
	mob = /mob/characterselect
	area = /area/outside
	cache_lifespan = 0
	view = 10
	New()
		. = ..()
		Startup()

	Del()
		SaveAll()
		. = ..()