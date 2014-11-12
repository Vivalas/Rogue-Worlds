#define SOUND_DISTANCE 10
#define SOUND_DIST_MULTIPLIER 1
#define SOUND_FALLOFF 2.5
var/list/playing_ambient = list()

atom/movable/var/ambientsnd/ambient_sound


proc
	GetWindNoise()
		return sound('Sounds/Weather/WindLoop.ogg',1,channel=2)

	ShipCreak()
		for(var/client/C)
			var/sound/s = sound(pick('Sounds/Ship/Creak1.ogg','Sounds/Ship/Creak2.ogg','Sounds/Ship/Creak3.ogg',
			'Sounds/Ship/Creak4.ogg','Sounds/Ship/Creak5.ogg'))
			s.x = (rand(8, 10) * pick(-1,1)) / SOUND_DIST_MULTIPLIER
			s.y = (rand(8, 10) * pick(-1,1)) / (SOUND_DIST_MULTIPLIER * 1.414)
			s.z = s.y + 0.5
			s.falloff = SOUND_FALLOFF
			C << s

atom/movable/Move(newLoc)
	if(ambient_sound && ambient_sound.is_playing) UpdateAmbientSound(newLoc)
	. = ..()

atom/movable/proc/UpdateAmbientSound(turf/N)
	for(var/client/C)
		var/mob/M = C.mob
		if(get_dist(M,N) > SOUND_DISTANCE)
			if(get_dist(M,src) <= SOUND_DISTANCE)
				M << sound(null, channel=ambient_sound.channel)
		else
			var/sound/S = sound(ambient_sound.file, 1, channel=ambient_sound.channel, volume=100)
			Set3DSound(S,N,M,ambient_sound.carry)
			M << S

proc/Set3DSound(sound/S,atom/A,mob/M,carry=10)
	//if(soundtester)
	//	if(ismob(A)) A = soundtester
	//	else if(ismob(B)) B = soundtester
	var/turf/B = M.loc
	S.x = (A.x - B.x) / SOUND_DIST_MULTIPLIER
	S.y = (A.y - B.y) / (SOUND_DIST_MULTIPLIER * 1.414)
	S.z = S.y + ((A.z-B.z)/(SOUND_DIST_MULTIPLIER*0.5)) + 0.5
	S.falloff = SOUND_FALLOFF
	//Basic occlusion
	if(!(M in hearers(A)))
		S.volume = carry
	S.status = SOUND_UPDATE

ambientsnd
	var
		file
		channel
		atom/movable/source
		is_playing = 0
		carry = 5
	New(atom/movable/source, file, carry, channel=0)
		src.file = file
		src.source = source
		src.channel = channel
		src.carry = carry
	Del()
		Stop()
		. = ..()
	proc
		Play()
			playing_ambient += src
			source.SoundAmbient(file,carry,channel)
			is_playing = 1
		Stop()
			playing_ambient -= src
			for(var/client/C)
				C << sound(null,channel=channel)
			is_playing = 0

mob/Move(newLoc)
	. = ..()
	if(client && . && isturf(loc)) UpdateAmbientSound(loc)

mob/UpdateAmbientSound(turf/N)
	for(var/ambientsnd/A in playing_ambient)
		if(!A.is_playing)
			playing_ambient -= A
			continue
		if(get_dist(N,A.source) > SOUND_DISTANCE)
			if(get_dist(src,A.source) <= SOUND_DISTANCE)
				src << sound(null, channel=A.channel)
		else
			var/sound/S = sound(A.file, 1, channel=A.channel)
			Set3DSound(S,A.source,src,A.carry)
			src << S

atom/proc/Sound(file, carry=10)
	//Ensuring that only currently connected players are caught by the iteration.
	if(istype(file,/atom)) CRASH("Sound file argument is [file:type]. Use Atom.Sound(file) syntax.")
	var/list/L = list()
	for(var/client/C)
		var/mob/M = C.mob
		L += M
		if(get_dist(src,M) > SOUND_DISTANCE) continue
		//if(M.deaf) continue
		//if(!M.play_sound) continue
		var/sound/S = sound(file)
		Set3DSound(S,src,M,carry)
		M << S
	return L

atom/proc/SoundAmbient(file, carry=10, channel)
	for(var/client/C)
		var/mob/M = C.mob
		if(get_dist(src,M) > SOUND_DISTANCE) continue
		//if(M.deaf) continue
		//if(!M.play_sound) continue
		var/sound/S = sound(file,1,channel=channel)
		Set3DSound(S,src,M,carry)
		M << S

atom/proc/SoundEx(file, carry=10, list/exclude)
	//Ensuring that only currently connected players are caught by the iteration.
	for(var/client/C)
		var/mob/M = C.mob
		if(M in exclude) continue
		if(get_dist(src,M) > SOUND_DISTANCE) continue
		//if(M.deaf) continue
		//if(!M.play_sound) continue
		var/sound/S = sound(file)
		Set3DSound(S,src,M,carry)
		M << S