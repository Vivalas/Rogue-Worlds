var/mob/pilot_of_ship = null

#define DOCKED 0
#define RISING 1
#define FLYING 2
#define SINKING 3

var
	ship_name = "The ship"
	ship_flying = 0
	ship_speed = 0
	ship_completion = 0
	time_to_port = MINUTES(3)
	current_port = 1
	returned_to_home = 0
	landing = 0
proc
	StartShip()
		spawn
			while(1)
				sleep(10)
				UpdateShip()
	GetCurrentPort()
		return round_ports[current_port]
	GetNextPort()
		if(current_port >= round_ports.len)
			return round_ports[1]
		return round_ports[current_port+1]
	UpdateShip()
		if(ship_flying)
			if(ship_completion < 600)
				if(ship_speed <= 1 || !pilot_of_ship)
					ship_completion -= 5 * (ship_speed == 0 ? 2 : 1)
					if(ship_completion <= 0)
						ship_flying = 0
						ship_completion = 0
						Announce("Departure has been postponed.")
						ChangeSpeed(0)
						UpdateSky("hover")
					return

			if(landing)
				if(ship_speed > 1 || !pilot_of_ship)
					ship_completion -= 5 * (ship_speed == 3 ? 2 : 1)
					if(ship_completion < time_to_port - 600)
						ship_completion = time_to_port - 600
					return
				else
					ship_completion += 10

					if(ship_completion >= time_to_port)
						current_port++
						if(current_port > round_ports.len)
							current_port = 1
						Announce("[ship_name] has landed at [GetCurrentPort()].")
						ship_flying = 0
						ship_completion = 0
						ChangeSpeed(0)
						UpdateSky("hover")
					return

			if(ship_completion > time_to_port - 600 && !landing)
				ship_completion = time_to_port - 600
				Announce("[ship_name] has arrived over [GetNextPort()]. All flight crew, please prepare for landing.")
				landing = 1
				return

			ship_completion += 5 * ship_speed

		else if(ship_speed > 1 && pilot_of_ship)
			Announce("[ship_name] has departed, and will arrive over [GetNextPort()] in [num2text(time_to_port/600,3)] minutes.")
			ship_flying = 1
			UpdateSky("")


	ChangeSpeed(n)
		if(n > 3) n = 0
		ship_speed = n
		for(var/ship/equipment/console/throttle/T)
			T.UpdateSpeed()

	UpdateSky(state)
		for(var/turf/T in world)
			sleep(-1)
			if(T.type == /turf)
				T.SetState(state)

	eta2text(eta) //eta in minutes to text format H:MM:SS
		var
			h = round(eta / 60)
			m = round(eta % 60) - h
			s = round(eta * 60) % 60

		return "[h]:[(m<10?"0":"")][m]:[(s<10?"0":"")][s]"


ship/equipment
	console
		icon = 'Icons/Ship/Equipment/Helm.dmi'
		var/lightstate = "light"
		var/image/light
		New()
			. = ..()
			light = image(icon,icon_state=lightstate,layer=101)
			overlays += light
		density = 1

		helm
			name = "Helm Console"
			icon_state = "controls"
			OperatedBy(mob/M)
				M.VisualMessage("[M] takes the helm.")
				pilot_of_ship = M
				if(!M.MoveTimer())
					M.VisualMessage("[M] leaves the helm.")
					pilot_of_ship = null

		nav
			name = "Navigation Console"
			icon_state = "controls2"
			lightstate = "light2"
			OperatedBy(mob/M)
				if(ship_flying)
					if(ship_completion < 600)
						M << "\red <b>Phase</b>: Takeoff"
					else if(!landing)
						M << "\red <b>Phase</b>: Cruising"
					else
						M << "\red <b>Phase</b>: Landing"
					var/eta
					if(landing || ship_speed == 0) eta = (time_to_port - ship_completion) / 600
					else eta = (time_to_port - ship_completion)/(600*ship_speed*0.5)
					M << "\red<b>ETA:</b> [eta2text(eta)]"
				else
					M << "\red Landed at [GetCurrentPort()]."


		throttle
			name = "Throttle"
			icon_state = "throttle"
			lightstate = "light3"
			var/image/lever

			New()
				. = ..()
				lever = image(icon, src, icon_state = "off", layer=-(layer+1))
				overlays += lever

			OperatedBy(mob/M)
				ChangeSpeed(ship_speed+1)

			proc/UpdateSpeed()
				overlays -= lever
				switch(ship_speed)
					if(1)
						lever.icon_state = "low"
					if(2)
						lever.icon_state = "med"
					if(3)
						lever.icon_state = "high"
					else
						lever.icon_state = "off"
				overlays += lever