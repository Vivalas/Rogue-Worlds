ship/box
	name = "Cargo Crate"
	icon = 'Icons/Ship/Box.dmi'
	var/lock = null
	var/nailed = null
	var/open = 0
	density = 1
	weight = 5

	New()
		. = ..()
		spawn(1) Close()

	OperatedBy(mob/M)
		if(!open)
			Open(M)
		else
			Close(M)

	AppliedBy(mob/M, item/I)
		if(!open)
			if(istype(I,/item/tool/hammer))
				if(!nailed)
					nailed = 1
					M.Sound('Sounds/Tools/Hammer.ogg')
					UpdateIcon()
				else
					nailed = 0
					M.Sound('Sounds/Tools/Crowbar.ogg')
					UpdateIcon()


	proc/Open(mob/M)
		if(nailed)
			M << "\red The box is nailed shut."
			return 0
		if(lock)
			M << "\red The box is locked."
			return 0
		for(var/item/I in src)
			I.Move(src.loc)
		open = 1
		Sound('Sounds/Structure/Creak.ogg')
		UpdateIcon()

	proc/Close(mob/M)
		for(var/item/I in loc)
			if(!I.isAnchored)
				I.Move(src)
		open = 0
		Sound('Sounds/Structure/BoxClose.ogg')
		UpdateIcon()

	proc/UpdateIcon()
		icon_state = ""
		if(lock)
			icon_state = "locked"
		if(nailed)
			icon_state += "nailed"
		if(open)
			icon_state += "open"

item/cargo
	var/gold_value = 0

	gold_coins
		icon = 'Icons/Items/Cargo/Coins.dmi'
		icon_state = "stack"
		name = "Coins"
		singular_name = "Coin"
		stack_size = 10
		max_stack_size = 10
		gold_value = 1

	gold_vase
		icon = 'Icons/Items/Cargo/Vase.dmi'
		name = "Gold Vase"
		gold_value = 15