var/codes = list("Bridge" = "Bridge","Security" = "Security","Chemistry" = "Chemistry","Engine" = "Engine",
"Locksmith" = "Locksmith","SecStorage" = "SecStorage","Medic" = "Medic")

proc/RandomizeLockCodes()
	for(var/code in codes)
		codes[code] = "[rand(1,999999)]"
		while(length(codes[code]) < 6)
			codes[code] = "0"+codes[code]
	for(var/ship/door/D)
		if(D.locked in codes)
			D.locked = codes[D.locked]

	for(var/item/locks/L)
		if(L.lockcode in codes)
			L.lockcode = codes[L.lockcode]

item/locks
	var/lockcode
	New(newLoc, code = "000000", label = "")
		lockcode = code
		src.label = label
		. = ..()
	lock
		name = "Lock"
		weight = 2
		icon = 'Icons/Items/Lock/Lock.dmi'
	key
		name = "Key"
		weight = 1
		icon = 'Icons/Items/Lock/Key.dmi'

	ExaminedBy(mob/M)
		. = ..()
		M << "The lock code is: [lockcode]"


item/container/keyring
	name = "Keyring"
	icon = 'Icons/Items/Lock/Keyring.dmi'
	icon_state = "0"
	weight = 1
	canEquipTo = "Belt"

	New()
		. = ..()
		AddKeys()

	OperatedBy(mob/M,atk)
		return ..(M,!atk)

	proc/Lockcodes()
		var/list/codes = list()
		for(var/item/locks/key/I in src)
			codes += I.lockcode
		return codes

	CheckInsert(item/I)
		return istype(I,/item/locks/key)

	Entered()
		. = ..()
		UpdateIcon()
	Exited()
		. = ..()
		UpdateIcon()

	proc/UpdateIcon()
		if(contents.len < 1) icon_state = "0"
		else if(contents.len == 1) icon_state = "1"
		else icon_state = ""

	proc/AddKeys()

	captain
		icon_state = ""
		AddKeys()
			for(var/c in codes)
				new/item/locks/key(src, codes[c], c)

proc/ChangeLockDigit(lockcode, pin, amt)
	var/digit = text2num(copytext(lockcode,pin,pin+1)) //Get the digit at that pin
	digit += amt //Add the amount
	digit = max(0,min(9,digit)) //Make sure it's a digit
	return copytext(lockcode,1,pin) + "[digit]" + copytext(lockcode,pin+1) //return new lockcode

proc/SetLockDigit(lockcode, pin, amt)
	var/digit = text2num(copytext(lockcode,pin,pin+1)) //Get the digit at that pin
	digit = amt //Set the amount
	digit = max(0,min(9,digit)) //Make sure it's a digit
	return copytext(lockcode,1,pin) + "[digit]" + copytext(lockcode,pin+1) //return new lockcode

ship/equipment/locksmith_machine
	name = "Locksmith's Machine"
	icon = 'Icons/Ship/Equipment/Locksmith.dmi'
	interfaceName = "locksmith"
	var/lockcode = "000000"
	var/item/operating_on
	AppliedBy(mob/M, item/I)
		if(!operating_on)
			var/slot = I.slot
			I = I.Pop()
			I.Move(src)
			operating_on = I
			M.EquipmentChanged(slot)
		OpenLocksmith(M)

	Exited(item/I)
		if(istype(I))
			operating_on = null
		. = ..()

	OperatedBy(mob/M)
		OpenLocksmith(M)

	InterfaceBy(mob/M, cmd)
		if(cmd == "Create")
			if(istype(operating_on,/item/construction/bars/gold))
				CreateKey()
			else if(istype(operating_on,/item/construction/sprockets))
				CreateLock()
			return
		var/space = findtext(cmd," ")
		var/bar_number = text2num(copytext(cmd,space+1))
		cmd = copytext(cmd,1,space)
		lockcode = ChangeLockDigit(lockcode, bar_number, (cmd=="Up"?1:-1))

		UpdateCode(M)

	proc
		OpenLocksmith(mob/M)
			M.OpenInterface(src)
			UpdateMaterial(M)
			UpdateCode(M)
			var/was_operating_on = operating_on
			while(M.interfacing_with == src)
				if(operating_on != was_operating_on)
					UpdateMaterial(M)
					was_operating_on = operating_on
				sleep(5)
				if(get_dist(M,src) > 1 && M.interfacing_with == src)
					M.CloseInterface()

		UpdateMaterial(mob/M)
			winset(M,"locksmith.Material","cells=0;current-cell=0")

			if(operating_on) M << output(operating_on, "locksmith.Material")
			if(istype(operating_on,/item/construction/bars/gold) || istype(operating_on,/item/construction/sprockets))
				winset(M,"locksmith.Code","text=\"Code: [Code()]\"")
			else if(istype(operating_on,/item/locks))
				winset(M,"locksmith.Code","text=\"Completed\"")
			else if(operating_on)
				winset(M,"locksmith.Code","text=\"Unusable Material\"")
			else
				winset(M,"locksmith.Code","text=\"No Material\"")

		UpdateCode(mob/M)
			var
				B1 = text2num(copytext(lockcode,1,2))
				B2 = text2num(copytext(lockcode,2,3))
				B3 = text2num(copytext(lockcode,3,4))
				B4 = text2num(copytext(lockcode,4,5))
				B5 = text2num(copytext(lockcode,5,6))
				B6 = text2num(copytext(lockcode,6))

			winset(M,"locksmith.Bar1","value=[B1*10 + 10]")
			winset(M,"locksmith.Bar2","value=[B2*10 + 10]")
			winset(M,"locksmith.Bar3","value=[B3*10 + 10]")
			winset(M,"locksmith.Bar4","value=[B4*10 + 10]")
			winset(M,"locksmith.Bar5","value=[B5*10 + 10]")
			winset(M,"locksmith.Bar6","value=[B6*10 + 10]")

			if(istype(operating_on,/item/construction/bars/gold) || istype(operating_on,/item/construction/sprockets))
				winset(M,"locksmith.Code","text=\"Code: [Code()]\"")
			else if(operating_on)
				winset(M,"locksmith.Code","text=\"Unusable Material\"")
			else
				winset(M,"locksmith.Code","text=\"No Material\"")

		Code()
			return lockcode

		CreateKey()
			var/item/locks/key/key = new(src)
			key.lockcode = lockcode
			del operating_on
			operating_on = key
		CreateLock()
			var/item/locks/lock/lock = new(src)
			lock.lockcode = lockcode
			del operating_on
			operating_on = lock