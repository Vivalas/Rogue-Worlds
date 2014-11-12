#define BAR_BG rgb(204,164,103)
#define BAR_FG rgb(190,139,63)
#define BAR_SELECTED rgb(192,192,192)

ship/door
	icon = 'Icons/Ship/Doors/Wooden.dmi'
	icon_state = "closed"
	material = /material/wood
	displaysMaterial = 1
	density = 0
	opacity = 1
	isAnchored = 1
	layer = 7
	interfaceName = "lockpick"
	var
		locked = 0
		item/bar
		system/door_bar/bar_overlay
		frame_type = /tile/wall_frame
		open = 0
		border = 0

		//Pick Interface
		pick_code = "999999"
		pin = 1

	New()
		. = ..()
		spawn(1) CheckBorder()

	PreventsCrossing(atom/movable/O)
		if((locked || bar) && !open)
			if(istype(O,/system/illusion)) return 0
			if(ismob(O) && !bar)
				var/mob/M = O
				if(CanUnlock(M)) return 0
			if(locked)
				O << "\red [src] is locked."
			if(bar)
				O << "\red [src] is barred."
			return 1
		else
			return 0

	Crossed(atom/movable/O)
		if(open) return ..()
		if((locked || bar) && istype(O,/system/illusion)) return ..()
		Open()
		spawn(20) TryClose()
		. = ..()

	OperatedBy(mob/M)
		if(!open)
			if((locked || bar))
				if(get_dist(M,bar_overlay) <= 1)
					bar_overlay.OperatedBy(M)
				return
			Open(1)
		else
			Close(1)

	AppliedBy(mob/M, item/I)
		if(istype(I,/item/construction/bars) && !open)
			if(!bar)
				bar = I.Pop()
				if(get_dir(M,src) & (get_dir(M,src)-1))
					for(var/turf/T in list(get_step(src,EAST),get_step(src,WEST),get_step(src,NORTH),get_step(src,SOUTH)))
						if(IsAccessible(M.loc,T))
							bar_overlay = new(T,src)
							break
				else
					bar_overlay = new(M.loc,src)

				switch(bar.type)
					if(/item/construction/bars/brass)
						bar_overlay.icon_state = "bar-brass bars"
					if(/item/construction/bars/planks)
						bar_overlay.icon_state = "bar-wood planks"
			else if(bar.type == I.type)
				del bar_overlay
				bar.TransferStacks(I,1)
		else if(istype(I,/item/tool/wrench))
			if(!locked && !bar)
				if(material.type == /material/wood)
					Deconstruct(M, WOODDOOR_DEC, I, "a wooden door", /item/construction/sprockets, WRENCH_SND)
				else
					Deconstruct(M, METALDOOR_DEC, I, "a metal door", /item/construction/sprockets, WRENCH_SND)
			else
				M << "\red This door cannot be taken down until the lock is removed."
		else if(istype(I,/item/locks/lock) && !locked)
			var/item/S = M.equipment.GetSupportItem(/item/tool/screwdriver)
			if(S)
				var/structname = "a wooden door"
				if(material.type == /material/iron) structname = "a metal door"
				M.VisualMessage(construction.sprintf(construction.lock_txt, M.name, structname))
				if(construction.Check(M, 30, I, S, SCREWDRIVER_SND))
					locked = I:lockcode
					ToLockedIcon()
					I.Consume()
					M.VisualMessage(construction.sprintf(construction.c_success_txt, FirstWord(M.name), structname))
				else
					M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))
		else if(istype(I,/item/tool/lockpicks) && locked)
			var/structname = "a wooden door"
			if(material.type == /material/iron) structname = "a metal door"
			M.VisualMessage(construction.sprintf(construction.lock_remove_txt, M.name, structname))
			if(construction.CheckMechanics(M, 100, I, null, LOCKPICK_SND))
				var/code = locked
				locked = 0
				var/item/locks/lock/L = new(M.loc)
				L.lockcode = code
				if(!M.equipment.GetSupportItem()) L.GetSupport(M)
				ToUnlockedIcon()
				Sound('Sounds/Structure/Lock.ogg')
				M.VisualMessage("[Capitalize(structname)] is unlocked.")
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))

		else if(istype(I,/item/tool/screwdriver) && locked)
			M.VisualMessage("\red [M] is picking the lock on [src]!")
			if(OpenLockpick(M))
				var/code = locked
				locked = 0
				var/item/locks/lock/L = new(M.loc)
				L.lockcode = code
				if(!M.equipment.GetSupportItem()) L.GetSupport(M)
				ToUnlockedIcon()
				M.VisualMessage("[M] picked the lock.")
			else
				M.VisualMessage(construction.sprintf(construction.failure_txt, FirstWord(M.name)))

	Vanish()
		new frame_type(loc)
		. = ..()

	InterfaceBy(mob/M, cmd)
		var/jump = 1
		if(!M.HasMechanicsSkill() && prob(35)) jump = 2
		switch(cmd)
			if("SwitchUp")
				SetPin(M)
				pin++
				if(pin > 6) pin = 1
				UpdatePin(M)
			if("SwitchDown")
				SetPin(M)
				pin--
				if(pin < 1) pin = 6
				UpdatePin(M)
			if("PushUp")
				M << 'Sounds/Tools/LockpickClick.ogg'
				pick_code = ChangeLockDigit(pick_code, pin, jump)
				if(copytext(pick_code,pin,pin+1) == copytext(locked,pin,pin+1) || prob(25)) M.Sound('Sounds/Tools/LockpickSuccess.ogg',5)
				//else if(prob(25)) M.Sound(pick('Sounds/Tools/LockpickFail1.ogg','Sounds/Tools/LockpickFail2.ogg'),5)
				UpdateCode(M)
			if("PushDown")
				M << 'Sounds/Tools/LockpickClick.ogg'
				pick_code = ChangeLockDigit(pick_code, pin, -jump)
				if(copytext(pick_code,pin,pin+1) == copytext(locked,pin,pin+1) || prob(25)) M.Sound('Sounds/Tools/LockpickSuccess.ogg',5)
				//else if(prob(25)) M.Sound(pick('Sounds/Tools/LockpickFail1.ogg','Sounds/Tools/LockpickFail2.ogg'),5)
				UpdateCode(M)
			if("Rake")
				M.Sound('Sounds/Tools/LockpickRake.ogg')
				if(prob(10))
					pick_code = locked
					UpdateCode(M)
				else
					pick_code = "999999"
					UpdateCode(M)
	proc
		CheckBorder()
			border = 0
			for(var/area/A in orange(src,1))
				if(A.type == /area/outside) border = 1
		Open(quiet)
			if(!open)
				icon_state = "open"
				flick("opening",src)
				Sound('Sounds/Structure/DoorOpen.ogg')
				SetOpacity(0)
				if(border) BORDER
				open = 1

		Close(quiet)
			if(open)
				for(var/atom/movable/A in loc)
					if(A.density) return 0
				icon_state = "closed"
				flick("closing",src)
				if(!quiet) Sound('Sounds/Structure/DoorClose.ogg')
				else Sound('Sounds/Structure/DoorCloseSoft.ogg')
				open = 0
				sleep(4)
				if(border) SetLight(0,0)
				if(!open) SetOpacity(1) //The door can be re-opened while it performs the closing animation.

				return 1

		TryClose()
			if(!Close())
				sleep(20)
				spawn TryClose()

		CanUnlock(mob/M)
			for(var/item/locks/key/I in M)
				if(I.lockcode == locked) return 1
			for(var/item/container/keyring/R in M)
				if(locked in R.Lockcodes()) return 1
			return 0

		OpenLockpick(mob/M)
			M.OpenInterface(src)
			UpdatePin(M)
			while(M.interfacing_with == src)
				if(get_dist(M,src) > 1) M.CloseInterface()
				if(pick_code == locked)
					M.CloseInterface()
					Sound('Sounds/Structure/Lock.ogg')
					pick_code = "999999"
					return 1
				sleep(5)
			pick_code = "999999"
			return 0

		UpdateCode(mob/M)
			for(var/i = 1 to 6)
				var/digit = text2num(copytext(pick_code,i,i+1))
				winset(M,"lockpick.Bar[i]","value=[digit*10 + 10]")
		SetPin(mob/M)
			var/pickdigit = text2num(copytext(pick_code,pin,pin+1))
			var/lockdigit = text2num(copytext(locked,pin,pin+1))
			if(pickdigit != lockdigit && prob(75))
				//M << "Wrong pin setting."
				pick_code = SetLockDigit(pick_code,pin,9)
		UpdatePin(mob/M)
			for(var/i = 1 to 8)
				winset(M,"lockpick.Bar[i]","background-color=[BAR_BG];bar-color=[BAR_FG]")
			winset(M,"lockpick.Bar[pin]","bar-color=[BAR_SELECTED]")
			UpdateCode(M)

		ToLockedIcon()
			icon = 'Icons/Ship/Doors/Wooden-Locked.dmi'
		ToUnlockedIcon()
			icon = 'Icons/Ship/Doors/Wooden.dmi'

	locked
		name = "Locked Door"
		icon = 'Icons/Ship/Doors/Wooden-Locked.dmi'
		locked = "Bridge"

	iron
		material = /material/iron
		frame_type = /tile/wall_frame/metal
		icon = 'Icons/Ship/Doors/Iron.dmi'

		ToLockedIcon()
			icon = 'Icons/Ship/Doors/Iron-Locked.dmi'
		ToUnlockedIcon()
			icon = 'Icons/Ship/Doors/Iron.dmi'

		locked
			name = "Locked Door"
			icon = 'Icons/Ship/Doors/Iron-Locked.dmi'
			locked = "Bridge"

system/door_bar
	icon = 'Icons/Ship/Doors/Wooden.dmi'
	icon_state = "bar-iron bars"
	var/ship/door/door
	New(loc,ship/door/door)
		. = ..()
		src.door = door
		layer = door.layer+1
		icon = door.icon
		switch(get_dir(src,door))
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32

	OperatedBy(mob/M)
		var/item/I = door.bar
		door.bar = null
		I.Move(loc)
		I.Get(M)
		del src