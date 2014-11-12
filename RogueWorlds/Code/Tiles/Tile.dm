tile
	parent_type = /obj
	var/material/material = /material/wood
	isAnchored = 1
	layer = 1
	New()
		. = ..()
		SetMaterial(material)
		var/turf/T = loc
		if(istype(T,/turf))
			T.AddBuilding(src)

	Del()
		var/turf/T = loc
		if(istype(T,/turf))
			T.RemoveBuilding(src)
		. = ..()

	proc/SetMaterial(mat)
		ASSERT(ispath(mat))
		if(istype(material,/material))
			name = material.object_name
		material = new mat(src)
		name = material.desc + " " + material.object_name

	proc/Footstep()
		Sound(pick('Sounds/Footsteps/Wood1.ogg','Sounds/Footsteps/Wood2.ogg','Sounds/Footsteps/Wood3.ogg',
		'Sounds/Footsteps/Wood4.ogg','Sounds/Footsteps/Wood5.ogg','Sounds/Footsteps/Wood6.ogg'))