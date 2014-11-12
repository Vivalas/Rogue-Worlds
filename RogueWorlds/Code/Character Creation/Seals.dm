var/list/abstract_seal_types = list(/seal,/seal/active)
var/list/all_seals = list()

proc/LoadSeals()
	var/list/possible_types = typesof(/seal) - abstract_seal_types
	for(var/type in possible_types)
		all_seals += new type()

proc/CreateSealPages(mob/M)
	var/pages_required = round(all_seals.len/6)+1
	if(pages_required > 1)
		winset(M,"sealpage1.next","is-visible=true")
		for(var/n = 2, n <= pages_required, n++)
			winclone(M,"sealpage1","sealpage[n]")
			winset(M,"sealpage[n].pagenumber","text=\"[n]\"")
			winset(M,"sealpage[n].back","is-visible=true")
			if(n < pages_required) winset(M,"sealpage[n].next","is-visible=true")

	var/sealcount = 0
	for(var/seal/S in all_seals)
		sealcount++
		var/page = round(sealcount / 6)+1
		var/index = (sealcount % 6)

		world << "[sealcount] - [S.name] P[page] I[index]"

		winset(M,"sealpage[page].sealicon[index]","image=[S.icon];is-visible=true")
		winset(M,"sealpage[page].sealtitle[index]","text=\"[S.name]\";is-visible=true")
		winset(M,"sealpage[page].sealdesc[index]","text=\"[S.desc]\";is-visible=true")


seal
	var
		icon/icon
		name
		desc

	proc/Effect(mob/human/user)
	proc/Available(mob/human/user)
		return 1

	vault
		name = "Spirit Vault"
		desc = "Passively cancels any illusions and mental/spiritual effects from seals or other supernatural objects. \
		Physical effects such as Supernatural Barrier will still happen. Preserves user's mind if transformed."
		icon = 'Textures/AbilityIcons/Vault.png'

	active //Can call Effect() whenever necessary.
		var/is_active = 0
		var/cooldown = 15
		var/last_used = 0

		Available(mob/human/user)
			if(last_used < world.time - cooldown || last_used <= 0 || is_active)
				return 1

		proc/Use(mob/human/user)
			if(Available(user))
				last_used = world.time
				spawn(cooldown*1+1) UpdateSeal(user)
				Effect(user)
			else
				user << "Cooldown has not expired."


		sn_barrier
			name = "Supernatural Barrier"
			desc = "Projects a visible wall on the tile beneath your character, which lasts for one minute."
			icon = 'Textures/AbilityIcons/SNBarrier.png'
			Effect(mob/human/user)
				var/obj/barrier/B = new(user.loc)
				is_active = 1
				spawn(600)
					RemoveBarrier(B)
					FadeSeal(user)

		illusion
			name = "Escaping Shadow"
			desc = "Projects an illusionary form of the character. You gain movement control of this illusion for up to one minute, \
			during which your actual body is intangible, but cannot move. Environmental damage still applies to your original body."
			icon = 'Textures/AbilityIcons/Illusion.png'
			Effect(mob/human/user)
				if(!is_active)
					var/system/illusion/I = new(user.loc)
					I.icon = user.icon
					I.overlays = user.overlays
					I.layer = user.layer
					I.user = user
					user.client.eye = I
					user.client.remote = I
					user.density = 0
					user.invisibility = 1
					user.sight |= SEE_SELF
					is_active = 1
					spawn(300) DeactivateSeal(user,src)
				else
					user.client.eye = user
					user.Sound('Sounds/Seals/Teleport.ogg', 0)
					user.client.remote.Sound('Sounds/Seals/Teleport.ogg',0)
					del user.client.remote
					user.density = 1
					user.invisibility = 0
					user.sight &= ~SEE_SELF
					var/image/I = image('Icons/Hazards/Tele.dmi',user,"[user.gender]in")
					I.override = 1
					world << I
					sleep(5)
					del I
					is_active = 0

		wall_break
			name = "Decoupler"
			desc = "After activation, the next dense, non-living object that the user clicks on is destroyed."
			icon = 'Textures/AbilityIcons/WallBreak.png'
			Effect(mob/human/user)
				is_active = !is_active
				last_used = 0

			proc/Break(atom/movable/A,mob/human/user)
				A.Destroy()
				last_used = world.time
				spawn(cooldown*1+1) UpdateSeal(user)
				is_active = 0
				user.SealChanged()

		teleporter
			name = "Blink"
			desc = "Teleports the user to a random location within a 5-tile radius, but outside of the user's previous view. \
			Automatically activates in conditions of imminent death by falling."
			icon = 'Textures/AbilityIcons/Teleporter.png'
			Effect(mob/human/user)
				var/list/candidates = list()
				for(var/turf/T in range(user.loc,5) - view(user.loc))
					if(user.CanMoveTo(T) && !T.canFallThrough) candidates.Add(T)
				if(!candidates.len)
					for(var/turf/T in range(user.loc,5))
						if(user.CanMoveTo(T) && !T.canFallThrough) candidates.Add(T)
					if(!candidates.len)
						last_used = 0
						return

				var/system/tele/T = new(user.loc)
				spawn T.Teleport("[user.gender]in")
				user.Move(pick(candidates))
				user.Sound('Sounds/Seals/Teleport.ogg',0)
				T.Sound('Sounds/Seals/Teleport.ogg', 0)
				var/image/I = image('Icons/Hazards/Tele.dmi',user,"[user.gender]in")
				I.override = 1
				world << I
				sleep(5)
				del I

obj/barrier
	name = "Supernatural Barrier"
	desc = "A thick shield of hard light which blocks movement and access."
	icon = 'Icons/Hazards/Magic.dmi'
	icon_state = "barrier"
	density = 1
	isAnchored = 1
	layer = 15
	canMoveOutOf = 1
	PreventsAccess(d)
		return 1
	New()
		. = ..()
		ambient_sound = new(src,'Sounds/Seals/Barrier.ogg',5,5)
		ambient_sound.Play()
	Del()
		del ambient_sound
		. = ..()

system/illusion
	name = "Shadow"
	desc = "Something is wrong with this person."
	invisibility = 0
	var/mob/human/user
	RemoteMove(turf/T)
		if(get_dist(src,T) <= 1 && user.CanMoveTo(T))
			return Move(T)

	Del()
		var/image/I = image('Icons/Hazards/Tele.dmi',src,"[user.gender]in")
		I.override = 1
		world << I
		sleep(5)
		. = ..()

system/tele
	name = "Zap!"
	desc = "You caught a glimpse of someone as they were teleported away."
	invisibility = 0
	layer = 15
	icon = 'Icons/Hazards/Tele.dmi'
	proc/Teleport(state)
		var/image/I = image('Icons/Hazards/Tele.dmi',src,"[state]")
		I.override = 1
		world << I
		sleep(5)
		del I
		del src

proc/RemoveBarrier(obj/barrier/B)
	B.Vanish()

proc/DeactivateSeal(mob/human/user, seal/active/seal)
	if(seal.is_active)
		seal.Effect(user)
		user.SealChanged()

proc/FadeSeal(mob/human/user, seal/active/seal)
	seal.is_active = 0
	user.SealChanged()

proc/UpdateSeal(mob/human/user)
	user.SealChanged()