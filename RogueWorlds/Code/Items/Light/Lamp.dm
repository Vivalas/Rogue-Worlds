item/light/lamp
	name = "Lamp"
	desc = "Contains a small flame to keep the ship lit up at night."
	icon = 'Icons/Items/Lamp.dmi'
	icon_state = "map"
	lightRadius = 4
	lightValue = 4
	OperatedBy(mob/M)
		if(icon_state == "unlit")
			icon_state = "lit"
			SetLight(4,4)
		else
			icon_state = "unlit"
			SetLight(0,0)
	New()
		. = ..()
		switch(dir)
			if(1)
				pixel_x = 0
				pixel_y = 32
			if(2)
				pixel_x = 0
				pixel_y = -32
			if(4)
				pixel_x = 32
				pixel_y = 0
			if(8)
				pixel_x = -32
				pixel_y = 0
		icon_state = "lit"