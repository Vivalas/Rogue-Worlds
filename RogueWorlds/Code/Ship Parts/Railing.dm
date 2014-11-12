ship/railing
	density = 0
	icon = 'Icons/Ship/Railing-base.dmi'
	dir = 2
	isAnchored = 1
	New()
		if(icon_state) dir = text2num(icon_state)
		if(dir & 2)
			layer = MOB_LAYER+1
		icon_state = num2text(dir)

	PreventsCrossing(mob/M,d)
		if(istype(M,/item)) return ..()
		if(M.loc != src.loc)
			if(d & turn(dir,180)) return 1
		else
			if(d & dir) return 1
		return ..()

	proc/UpdateRails()
		for(var/ship/railing/R in loc)
			if(R == src) continue
			dir |= R.dir
			R.Vanish()
		icon_state = num2text(dir)

	AppliedBy(mob/M, item/I)
		if(istype(I,/item/tool/wrench))
			Deconstruct(M, 10, I, "a section of railing", /item/construction/bars/brass, WRENCH_SND)