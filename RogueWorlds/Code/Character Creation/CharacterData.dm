var
	def_skinbase = "#C69462"
	def_skinoutline = "#946230"
	def_skinhighlights = "#DFAD7B"
	def_eyecolor = "#5F1921"

	list/names_male = list()
	list/names_female = list()
	list/names_last = list()

characterdata
	var
		name = "Character Name"
		gender = NEUTER
		age = 20
		hairstyle = "Bald"
		haircolor = "#000000"
		beardstyle = "None"
		//eyecolor = "#000000"
		textcolor = "#000000"
		skincolor = "#000000"
		alt_skill = NOSKILLS
		job1 = ""
		job2 = ""
		job3 = ""
		notes = ""
		creationdate = ""

		tmp
			seal/seal
			job/job
			skills = NOSKILLS
			system/image

	New()
		gender = pick(MALE,FEMALE)
		name = RandomName(gender)
		skincolor = RandomSkintone()
		haircolor = RandomColor()
		textcolor = toTextColor(RandomColor())
		hairstyle = pick(Hairstyles())
		creationdate = time2text(world.timeofday,"DD/MM/YYYY")
		image = new()
		UpdateImage()
		UpdateImageHair()

	Read(savefile/F)
		. = ..()
		if("seal" in F.dir)
			F["seal"] >> seal
			seal = new seal()
		image = new()
		UpdateImage()
		UpdateImageHair()

	Write(savefile/F)
		. = ..()
		if(seal)
			F["seal"] << seal.type

	proc/ReadFromInterface(mob/M)
		name = winget(M,"charcreation.name","text")
		age = winget(M,"charactercreation.age","text")
		notes = winget(M,"charcreation.notes","text")

	proc/WriteToInterface(mob/M)
		winset(M,"name","text=\"[name]\"")
		if(gender == MALE)
			winset(M,"male","is-checked=true")
			winset(M,"facialhair","is-visible=true;text=\"[beardstyle]\"")
		else
			winset(M,"female","is-checked=true")
			winset(M,"facialhair","is-visible=false")
		winset(M,"age","text=\"[age]\"")
		winset(M,"hairstyle","text=\"[hairstyle]\"")
		winset(M,"haircolor","background-color=[haircolor]")
		winset(M,"textcolor","text-color=[textcolor]")
		winset(M,"skincolor","background-color=[skincolor]")
		for(var/n = 1 to 3)
			winset(M,"job[n]","text=\"[vars["job[n]"]]\"")
		winset(M,"notes","text=\"[notes]\"")
		winset(M,"date","text=\"Date: [creationdate]\"")
		if(seal)
			winset(M,"sealicon","image=[seal.icon]")
			winset(M,"sealname","text=\"Seal: [seal.name]\"")
		else
			winset(M,"sealicon","image=")
			winset(M,"sealname","text=\"Seal: Not Selected\"")


	proc/Hairstyles()
		if(gender == MALE)
			return icon_states('Icons/Creatures/Players/MaleHair.dmi')
		else
			return icon_states('Icons/Creatures/Players/FemaleHair.dmi')

	proc/UpdateImage()
		//var/icon/background = icon('Icons/Tiles/Floor.dmi',"iron")
		var/icon/I = icon((gender==MALE)?'Icons/Creatures/Players/Male.dmi':'Icons/Creatures/Players/Female.dmi',"example")

		var/skinrgb = inverse_rgb(skincolor)

		var/skinbase = skincolor
		var/skinoutline = rgb(skinrgb[1]-20,skinrgb[2]-20,skinrgb[3]-20)
		var/skinhighlights = rgb(skinrgb[1]+20,skinrgb[2]+20,skinrgb[3]+20)

		I.SwapColor(def_skinbase, skinbase)
		I.SwapColor(def_skinoutline, skinoutline)
		I.SwapColor(def_skinhighlights, skinhighlights)

		//I.Blend(background,ICON_UNDERLAY)

		I.Shift(SOUTH,2)

		image.icon = I

	proc/UpdateImageHair()
		image.overlays.len = 0
		var/icon/I = icon((gender==MALE)?'Icons/Creatures/Players/MaleHair.dmi':'Icons/Creatures/Players/FemaleHair.dmi', hairstyle)
		I.Blend(haircolor)
		I.Shift(SOUTH,2)
		image.overlays += I
		if(gender==MALE)
			I = icon('Icons/Creatures/Players/Beards.dmi', beardstyle)
			I.Blend(haircolor)
			I.Shift(SOUTH,2)
			image.overlays += I

	proc/GenerateHumanIcon(mob/human/human)
		var/icon/I = icon((gender==MALE)?'Icons/Creatures/Players/Male.dmi':'Icons/Creatures/Players/Female.dmi')

		var/skinrgb = inverse_rgb(skincolor)

		var/skinbase = skincolor
		var/skinoutline = rgb(skinrgb[1]-20,skinrgb[2]-20,skinrgb[3]-20)
		var/skinhighlights = rgb(skinrgb[1]+20,skinrgb[2]+20,skinrgb[3]+20)

		I.SwapColor(def_skinbase, skinbase)
		I.SwapColor(def_skinoutline, skinoutline)
		I.SwapColor(def_skinhighlights, skinhighlights)

		//I.Blend(background,ICON_UNDERLAY)

		var/icon/H = icon((gender==MALE)?'Icons/Creatures/Players/MaleHair.dmi':'Icons/Creatures/Players/FemaleHair.dmi', hairstyle)
		H.Blend(haircolor)
		if(gender==MALE)
			var/icon/B = icon('Icons/Creatures/Players/Beards.dmi', beardstyle)
			B.Blend(haircolor)
			H.Blend(B,ICON_OVERLAY)

		var/icon/DI = icon(I)
		DI.Turn(90)
		DI.Shift(SOUTH,8)

		I.Insert(DI,"down")

		DI = icon(H)
		DI.Turn(90)
		DI.Shift(SOUTH,8)
		H.Insert(DI,"down")

		human.icon = I
		human.hair = image(H, layer = -101)

	proc/RandomSkintone()
		var/h = 20
		var/s = 100
		var/v = 50

		h += rand(-10,10)
		s += rand(0,100)
		v += rand(0,150)

		return "#"+hsl2rgb(h,s,v)
	proc/RandomColor()
		return rgb(rand(50,200),rand(50,200),rand(50,200))

	proc/HasSkill(skill)
		return alt_skill & skill

proc/LoadNames()
	var/name_file = "names.txt"
	if(fexists(name_file))
		var/data = file2text(name_file)
		var/list/splitdata = dd_text2list(data,"\n\n")
		names_male = dd_text2list(splitdata[1],"\n")
		names_female = dd_text2list(splitdata[2],"\n")
		names_last = dd_text2list(splitdata[3],"\n")
	for(var/name in names_male)
		if(copytext(name,1,3) == "//") names_male -= name
	for(var/name in names_female)
		if(copytext(name,1,3) == "//") names_female -= name
	for(var/name in names_last)
		if(copytext(name,1,3) == "//") names_last -= name



proc/RandomName(gender)
	if(names_male.len <= 0 || names_female.len <= 0) return "Error"
	var/first = pick((gender==MALE)?(names_male):(names_female))
	var/last = pick(names_last)

	var/variation = rand(1,100)
	if(variation <= 50)
		return "[first] [last]"
	else //if(variation <= 75)
		return "[first] [Letter()]. [last]"
	/*else
		var/middle = pick(character_names)
		if(prob(50))
			middle = copytext(middle, findtext(middle, " ") + 1)
		else
			middle = copytext(middle, 1, findtext(middle, " "))
		return "[first] [middle] [last]"*/

proc/Letter()
	return ascii2text(rand(65,90))