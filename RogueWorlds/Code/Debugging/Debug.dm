var/debug_messages = 1

var/list/soundtesters = list()

//Prints a debug message. Can be shut off by debug_messages = 0.
proc/dbg(txt)
	if(debug_messages)
		world << "DBG: [txt]"
		//world.log << "DBG: [txt]"

item/debug_item
	icon = 'Icons/Debug/Item.dmi'
	name = "Debug Item"
	material = /material/wood

mob/verb/Outside(n as num)
	OutsideLight(n)

obj/fire
	icon = 'Icons/Hazards/Pipes.dmi'
	lightValue = 3
	lightRadius = 3


var/mob/dbg_ninja

mob/verb/Summon_Ninja()
	dbg_ninja.Move(get_step_rand(loc))

mob/verb/Ports()
	for(var/port/P in round_ports)
		P.Debug()

proc/TestCharacters()
	while(1)
		sleep(rand(50,150))
		var/mob/human/sound_tester/M = pick(soundtesters)
		M.TestingAI()

mob/human/sound_tester
	name = "John Egbert"
	gender = MALE
	var/textcolor = "#0000FF"
	var/job/job = /job/scientist
	New()
		. = ..()
		//soundtesters += src
		data.textcolor = textcolor
		job = new job()
		job.AssignInventory(src)

	proc/TestingAI()
		var/choice = pick("swag","swag","mothafuckin","swag","weed")
		var/words = ProduceSentence()
		var/list/all_pplz = list()
		for(var/mob/human/M) all_pplz += copytext(M.name,1,findtext(M.name," "))
		words = dd_replacetext(words, "{person}", pick(all_pplz))
		if(choice == "mothafuckin")
			Shout(words)
		else if(choice == "weed")
			Whisper(words)
		else
			Say(words)

	AppliedBy(mob/M, item/I)
		I.Drop(M,loc)
		I.Get(src)

	harley
		name = "Jade Harley"
		textcolor = "#00FF00"
		gender = FEMALE

	strider
		name = "Dave Strider"
		textcolor = "#FF0000"
		job = /job/security
		HasCombatSkill()
			return 1

	madoka
		name = "Madoka Kaname"
		textcolor = "#FFAAFF"
		gender = FEMALE
		New()
			. = ..()
			spawn WalkingAI()
		proc/WalkingAI()
			while(src)
				sleep(5)
				if(prob(5) && !fight_target)
					var/attempts = 6
					while(attempts > 0)
						attempts--
						var/turf/T = get_step_rand(src)
						var/tile/I = locate() in T
						if(!I) continue
						if(!CanMoveTo(T)) continue
						Move(T)
						break
				if(!CanFight())
					continue
				if(fight_target)
					if(get_dist(src,fight_target) > 1)
						step_to(src,fight_target)
					else
						EnterFight(fight_target)
				else
					sleep(5)
					for(var/mob/M in view(src))
						if(istype(M.fight_target,/mob/human/sound_tester))
							fight_target = M

		sayaka
			name = "Sayaka Miki"
			textcolor = "#AAFFFF"


		kyuubey
			name = "Kyuubey"
			textcolor = "#FFFFFF"
			gender = MALE
			var/seal/active/sn_barrier/seal
			var/last_seal = 0
			HasCombatSkill()
				return 1
			New()
				. = ..()
				seal = new
			TestingAI()
				var/choice = pick("swag","swag","mothafuckin","swag","weed")
				var/words = ProduceSentence()
				var/list/all_pplz = list()
				for(var/mob/human/M) all_pplz += copytext(M.name,1,findtext(M.name," "))
				words = dd_replacetext(words, "{person}", pick(all_pplz))
				if(choice == "mothafuckin")
					Shout(words)
				else if(choice == "weed" && !(locate(/obj/barrier) in loc))
					seal.Effect(src)
				else
					Say(words)

	assassin
		name = "Doctor McNinja"
		textcolor = "#FFCC55"
		gender = MALE
		job = /job/officer
		New()
			. = ..()
			dbg_ninja = src
		OperatedBy(mob/user)
			user << "\red [src] is about to assassinate some bitches."
			sleep(50)
			var/list/victims = list()
			for(var/mob/M in view(src))
				if(M == src) continue
				if(M == user) continue
				victims += M
			fight_target = pick(victims)
			spawn KillingAI()

		proc/KillingAI()
			while(fight_target)
				sleep(5)
				if(!CanFight())
					ExitFight(1)
				if(get_dist(src,fight_target) > 1)
					step_to(src,fight_target)
				else
					EnterFight(fight_target)

	tele_tester
		name = "Alice N. Wonderland"
		gender = FEMALE
		var/seal/active/teleporter/teleseal
		New()
			. = ..()
			teleseal = new
		OperatedBy(mob/M)
			teleseal.Effect(src)
		TestingAI()
			teleseal.Effect(src)

var/list/debug_words = list(
"So {person}",
"You're Pretty",
"Oh, hey {person}",
"{person}, NO",
"FUCKITY FUCK FUCK ON A FUCKSTICK FUCK",
"I plan to assassinate {person} at midnight tonight",
"I plan to take my pants off first thing in the morning",
"The world is mine",
"Sup dawg",
"Swag, swag, mothafuckin swag, weed and the smoking of it erryday",
"Contract",
"Become meguca",
"I become meguca for {person}",
"There is still hope",
"BUUUURN MY BREAAAAAD",
"Roses are pink, Jadesprite is green, the code word is deep if you know what I mean",
"{person} should go jump in a deep lake.",
"You must be STRONG.",
"I HAVE NOW CONQUERED FOUR PLANETS, AND HAVE THE SAME AMOUNT OF GNOMES UNDER MY COMMAND.",
"You can't kill purple hat. He's too lucky!"
)

/*mob/verb/GenerateClockIcons()
	set background = 1
	dbg("Generating Clock Icons")
	for(var/h = 0 to 11)
		for(var/m = 0 to 59)
			var/qh = (h % 3)
			var/qm = (m % 15)

			var/icon/full = icon('Interface/ClockFace.dmi',"")

			//world << "\icon[full] face"

			var/icon/minute = icon('Interface/Minutes.dmi',"[qm]")
			var/q = round(m / 15)
			for(var/i = 1, i <= q, i++)
				minute.Turn(90)

			//world << "\icon[minute] min:[m]"

			var/icon/hour = icon('Interface/Hours.dmi',"[qh]")
			q = round(h / 3)
			for(var/i = 1, i <= q, i++)
				hour.Turn(90)

			//world << "\icon[hour] hour:[h]"

			var/icon/front = icon('Interface/ClockFace.dmi',"cover")

			full.Blend(hour, ICON_OVERLAY)
			full.Blend(minute, ICON_OVERLAY)
			full.Blend(front, ICON_OVERLAY)

			//world << "\icon[full] complete"
			var/inumber = ((h*60)+m)
			src << ftp(full,"Clock[inumber+1].dmi")
			world << "[ (inumber / 720) ]% Complete"

mob/verb/PrintEnormousClockList()
	var/str = "var/list/clock_icons = list("
	for(var/i = 1 to 720)
		str += "'Textures/Clock/Clock[i].dmi',"
		if(i % 4 == 0) str += "\n"
	str += ")"
	world << str*/