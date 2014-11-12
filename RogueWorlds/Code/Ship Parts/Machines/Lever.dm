ship/equipment/lever
	icon = 'Icons/Ship/Equipment/Lever.dmi'
	icon_state = "left"
	OperatedBy(mob/M)
		if(machine_id)
			MachineTrigger(machine_id)
		else
			M << "\red The lever is stuck."

	MachineOperate()
		Sound('Sounds/Structure/Lever.ogg')
		if(icon_state == "left")
			icon_state = "right"
		else
			icon_state = "left"