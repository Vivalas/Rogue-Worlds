ship
	parent_type = /obj
	var/material/material = /material
	var/displaysMaterial = 0
	var/machine_id
	New()
		. = ..()
		SetMaterial(material)
		if(!displaysMaterial)
			name = material.object_name
	proc/SetMaterial(mat)
		ASSERT(ispath(mat))
		if(istype(material,/material))
			name = material.object_name
		material = new mat(src)
		name = material.desc + " " + material.object_name

	proc/MachineOperate()

proc/MachineTrigger(m)
	ASSERT(m)
	for(var/ship/S)
		if(S.machine_id == m)
			S.MachineOperate()