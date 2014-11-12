mob/characterselect
	Login()
		winshow(src,"charselect",1)
		LoadCharacters()
		src << browse_rsc('Textures/Backgrounds/ParchmentBox.png',"parchment.png") //For dialog boxes
		CreateSealPages(src)
		CreateJobPages(src)

	var/selected = 1

	var/sealpage = 1
	var/jobpage = 1
	var/jobselected = 1
	var/ready = 0

	var/characterdata
		Character1
		Character2
		Character3

		Selected

	proc
		UpdateCharSelect()
			for(var/i = 1, i <= 3, i++)
				var/characterdata/data = vars["Character[i]"]
				if(data)
					winset(src,"charselect.Character[i]","text=\"[data.name]\"")
					winset(src,"charselect.Icon[i]","cells=1")
					src << output(data.image, "charselect.Icon[i]")
				else
					winset(src,"charselect.Character[i]",{"text="New Character""})
					winset(src,"charselect.Icon[i]","cells=0")

			if(round_started)
				winset(src,"charselect.ready","text=\"Join\"")
			else
				winset(src,"charselect.ready","text=\"Ready\"")

			Selected = vars["Character[selected]"]

			if(Selected)
				winset(src,"charselect.edit","text=\"Edit\"")
				winset(src,"charselect.delete", "is-disabled=false")
				winset(src,"charselect.ready", "is-disabled=false")
			else
				winset(src,"charselect.edit","text=\"Create\"")
				winset(src,"charselect.delete", "is-disabled=true")
				winset(src,"charselect.ready", "is-disabled=true")

		LoadCharacters()
			//world << "Loading from Save/[ckey]"
			if(fexists("Save/[ckey]/Characters.sav"))
				var/savefile/file = new/savefile("Save/[ckey]/Characters.sav")
				if("Char1" in file.dir)
					file["Char1"] >> Character1
					//world << "Found Character: [Character1.name]"
				if("Char2" in file.dir)
					file["Char2"] >> Character2
					//world << "Found Character: [Character2.name]"
				if("Char3" in file.dir)
					file["Char3"] >> Character3
					//world << "Found Character: [Character3.name]"
			UpdateCharSelect()

		SaveSelectedCharacter()
			//world << "Saving to Save/[ckey]"
			var/savefile/file = new/savefile("Save/[ckey]/Characters.sav")
			file["Char[selected]"] << Selected

		DeleteSelectedCharacter()
			if(fexists("Save/[ckey]/Characters.sav"))
				var/savefile/file = new/savefile("Save/[ckey]/Characters.sav")
				var/list/dir = file.dir
				dir.Remove("Char[selected]")
			del Selected

		MakeNewCharacter(n)
			Selected = new/characterdata
			EditCurrentCharacter()
			selected = n

		EditCurrentCharacter()
			winshow(src,"charcreation",1)
			winshow(src,"charselect",0)

			Selected.WriteToInterface(src)

			src << output(Selected.image,"icon")

		SetHair(style, color)
			winset(src,"hairstyle","text=\"[style]\"")
			winset(src,"haircolor","background-color=[color]")
			Selected.hairstyle = style
			Selected.haircolor = color
			Selected.UpdateImageHair()
			src << output(Selected.image,"icon")

		SetBeard(style)
			winset(src,"facialhair","text=\"[style]\"")
			Selected.beardstyle = style
			Selected.UpdateImageHair()
			src << output(Selected.image,"icon")

		SetEyes(color)
			Selected.textcolor = toTextColor(color)
			//Current.eyecolor = color
			//winset(src,"eyecolor","background-color=[Current.textcolor]")
			winset(src,"textcolor","text-color=[Selected.textcolor]")

		SetSkin(color)
			winset(src,"skincolor","background-color=[color]")
			Selected.skincolor = color
			Selected.UpdateImage()
			src << output(Selected.image,"icon")
	verb
		SelectCharacter(n as num)
			if(n < 1 || n > 3) return
			selected = n
			UpdateCharSelect()

		EditCharacter()
			if(!Selected) Selected = new/characterdata()
			EditCurrentCharacter()

		DeleteCharacter()
			var/css = {"<style>
			BODY {
				font:georgia;
				background-color:#CCA467;
				background-image:url('parchment.png');
				color:black;
				}
			SELECT	{
				background: #CCA467;
				color: black;
				}
			</style>"}
			var/answer = sd_Alert(src, "Are you sure you want to delete [vars["Character[selected]"]]?", "Delete Character",
				list("Yes","No"),
				"No",0,0,"240x160",,css,,0)
			if(answer == "Yes")
				DeleteSelectedCharacter()
				UpdateCharSelect()


		ChangeColor(cmd as text)
			switch(cmd)
				if("Hair")
					src.getColor("Hair_Color",Selected.haircolor)
				if("Eyes")
					src.getColor("Text_Color",Selected.textcolor)
				if("Skin")
					src.getColor("Skin_Color",Selected.skincolor)

		Gender_Male()
			Selected.gender = MALE
			winset(src,"facialhair","is-visible=true;text=\"[Selected.beardstyle]\"")

		Gender_Female()
			Selected.gender = FEMALE
			winset(src,"facialhair","is-visible=false")

		ChangeHair()
			var/list/styles = Selected.Hairstyles()
			var/css = {"<style>
			BODY {
				font:georgia;
				background-color:#CCA467;
				background-image:url('parchment.png');
				color:black;
				}
			SELECT	{
				background: #CCA467;
				color: black;
				}
			</style>"}
			var/selection = sd_Alert(src, "Select a hairstyle.", "Hairstyle", styles, \
				Selected.hairstyle,0,0,"240x160",,css,,1)
			SetHair(selection,Selected.haircolor)

		ChangeFacialHair()
			var/list/styles = icon_states('Icons/Creatures/Players/Beards.dmi')
			var/css = {"<style>
			BODY {
				font:georgia;
				background-color:#CCA467;
				background-image:url('parchment.png');
				color:black;
				}
			SELECT	{
				background: #CCA467;
				color: black;
				}
			</style>"}
			var/selection = sd_Alert(src, "Select a facial hair style.", "Facial Hair", styles, \
				Selected.beardstyle,0,0,"240x160",,css,,1)
			SetBeard(selection)

		ChangeSeal()
			winshow(src,"sealpage[sealpage]",1)

		SelectSeal(n as num)
			var/seal/S = all_seals[(sealpage-1)*6+n]
			Selected.seal = new S.type
			winset(src,"sealicon","image=[S.icon]")
			winset(src,"sealname","text=\"Seal: [S.name]\"")
			winshow(src,"sealpage[sealpage]",0)

		SealPageNext()
			winshow(src,"sealpage[sealpage]",0)
			sealpage++
			winshow(src,"sealpage[sealpage]",1)

		SealPageBack()
			winshow(src,"sealpage[sealpage]",0)
			sealpage--
			winshow(src,"sealpage[sealpage]",1)

		ChangeJob(n as num)
			jobselected = n
			winshow(src,"jobpage[jobpage]",1)

		SelectJob(n as num)
			var/job/J = selectable_jobs[(jobpage-1)*10+n]
			Selected.vars["job[jobselected]"] = J.name
			winset(src,"job[jobselected]","text=\"[J.name]\"")
			winshow(src,"jobpage[jobpage]",0)

		JobPageNext()
			winshow(src,"jobpage[jobpage]",0)
			sealpage++
			winshow(src,"jobpage[jobpage]",1)

		JobPageBack()
			winshow(src,"jobpage[jobpage]",0)
			sealpage--
			winshow(src,"jobpage[jobpage]",1)

		DbgDumpSeals()
			var/n = 1
			for(var/seal/S in all_seals)
				world << "[n++] - [S.name]: [S.desc]"

		Confirm()
			Selected.ReadFromInterface(src)
			vars["Character[selected]"] = Selected

			SaveSelectedCharacter()
			Selected = null
			winshow(src,"charcreation",0)
			winshow(src,"charselect",1)
			UpdateCharSelect()

		Deny()
			Selected = null
			winshow(src,"charselect",1)

		Quit()
			del Selected
			del src

		Ready()
			var/characterdata/selected_data = Selected
			if(!selected_data) return
			if(!round_started)
				if(!ready)
					ready_players += src
					ready = 1
					if(ReadyCheck())
						StartRound()
				else
					ready_players -= src
					ready = 0
			else
				winshow(src,"charselect",0)
				var/mob/human/H = new/mob/human(Selected)
				passenger_job.AssignInventory(H)
				H.client = client

	Topic(href,data[])
		var/r=text2num(data["r"])
		var/g=text2num(data["g"])
		var/b=text2num(data["b"])
		var/color = rgb(r,g,b)

		src << "[color]"

		switch(data["command"])
			if("Hair_Color")
				SetHair(Selected.hairstyle,color)
			if("Text_Color")
				SetEyes(color)
			if("Skin_Color")
				SetSkin(color)

		usr<<browse(null,"window=[data["command"]]")

var/tcolor_mul = 0.25
var/tcolor_bound = 120
proc
	toTextColor(color)
		var
			rgb = inverse_rgb(color)
			r = rgb[1]//*(1-tcolor_mul)
			g = rgb[2]//*(1-tcolor_mul)
			b = rgb[3]//*(1-tcolor_mul)
		var/max = max(r,g,b)
		if(max < tcolor_bound)
			r += tcolor_bound - max
			g += tcolor_bound - max
			b += tcolor_bound - max
		return rgb(r,g,b)
	/*toEyeColor(color)
		var
			rgb = inverse_rgb(color)
			r = rgb[1]*tcolor_mul
			g = rgb[2]*tcolor_mul
			b = rgb[3]*tcolor_mul
		return rgb(r,g,b)*/