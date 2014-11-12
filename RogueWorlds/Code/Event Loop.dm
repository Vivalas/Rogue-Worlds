proc/UpdateLoop() //For things that add to the game, but won't stop the round by being slow.
	var/ticks = 0
	while(1)
		sleep(1)
		ticks++
		if(ticks % 5 == 0)
			for(var/mob/M in world)
				M.Life()


proc/ObjectiveLoop() //For important shit!

#define WEATHER_CHANGE_TIME rand(60,180)
#define SHIP_CREAK_TIME rand(20,60)

proc/WeatherLoop()
	var/next_weather_change = WEATHER_CHANGE_TIME
	var/next_ship_creak = SHIP_CREAK_TIME
	while(1)
		sleep(50)
		next_ship_creak--
		next_weather_change--
		if(next_ship_creak <= 0)
			ShipCreak()
			next_ship_creak = SHIP_CREAK_TIME
		if(next_weather_change <= 0)
			//TODO: Change The Weather
			next_weather_change = WEATHER_CHANGE_TIME

proc/Startup()
	LoadNames()
	LoadJobs()
	LoadSeals()
	InitializeTime()
	JoinTables()
	GenerateCopyList()
	LoadSentenceMixing()
	RandomizeLockCodes()
	spawn ObjectiveLoop()
	spawn UpdateLoop()
	spawn WeatherLoop()
	LoadBooks()
	//spawn TestCharacters()

proc/SaveAll()
	del chem
	SaveBooks()
	SaveSentenceMixing()