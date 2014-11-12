mob/verb/RenderGas()
	dbg("Generating Flasks...")
	var/icon/gas = icon('Icons/Chemicals/FlaskBase.dmi',"tube")
	var/icon/colors = new('Icons/Chemicals/Colors.dmi')
	for(var/s in icon_states(colors))
		var/icon/C = icon('Icons/Chemicals/FlaskBase.dmi',"tube")
		C.SwapColor(rgb(0,0,0), colors.GetPixel(1,1,s))
		gas.Insert(C, s)
	src << ftp(gas,"Icons/Chemicals/TestTube.dmi")

mob/verb/CheckMath()
	world << "sin(90) = [sin(90)]"
	world << "sin(270) = [sin(270)]"
	world << "PI = [PI]"
	world << "sin(pi/2) = [rsin(PI/2)]"
	world << "sin(pi+pi/2) = [rsin(PI + PI/2)]"

/*
		name = "swirling blue gas"
		r_name = "Antinine"
		color = "blue"
		state = "gas"
		matrix = list(
		"Toxicity" = 0,
		"Antibiotic" = 0,
		"Metabolic Speed" = 120,
		"HealToxic" = 0,
		"Alkalinity" = 20,
		"StaminaGainB" = 0,
		"VolatilityA" = 55,
		"Density" = 3,
		"PhysDamage" = 0,
		"StaminaDrain" = 0,
		"Acidity" = 0,
		"Pain" = 0,
		"HealPain" = 0,
		"StaminaGainA" = 0,
		"UnusedB" = 0,
		"Catalysis" = 50,
		"UnusedD" = 0,
		"Flammability" = 200,
		"VolatilityB" = 25,
		"HealPhys" = 0,
		"Slipperiness" = 50,
		"RadioactivityA" = 0,
		"Antivirus" = 0,
		"HealBurn" = 0,
		"RadioactivityS" = 0,
*/

proc/ConvertElements(list/effects)
	var/list/matrix = base_matrix.Copy()
	for(var/e in effects)
		switch(e)
			if("Toxicity")
				matrix["Toxicity"] += effects[e]/2
			if("HealToxic")
				matrix["Toxicity"] -= effects[e]/2
			if("Alkalinity")
				matrix["Acidity"] += effects[e]/4
			if("StaminaGainB")
				matrix["Stamina"] += effects[e]/4
			if("VolatilityA")
				matrix["VolatilityA"] = effects[e]/2
			if("Density")
				matrix["Density"] = effects[e]
			if("PhysDamage")
				matrix["Pierce"] += effects[e]/2
			if("StaminaDrain")
				matrix["Stamina"] += effects[e]/2
			if("Acidity")
				matrix["Acidity"] += effects[e]/4
			if("Pain")
				matrix["Pain"] += effects[e]/2
			if("HealPain")
				matrix["Pain"] -= effects[e]/2
			if("StaminaGainA")
				matrix["Stamina"] += effects[e]/4
			if("Catalysis")
				matrix["Catalysis"] = effects[e]
			if("Flammability")
				matrix["Flammable"] = effects[e]/2
			if("VolatilityB")
				matrix["VolatilityB"] = effects[e]/2
			if("HealPhys")
				matrix["Pierce"] -= effects[e]/2
			if("Slipperiness")
				matrix["Slippery"] += effects[e]/2
			if("RadioactivityA")
				matrix["RARadius"] = effects[e]/2
			if("HealBurn")
				matrix["Burn"] -= effects[e]/2
			if("RadioactivityS")
				matrix["Radioactive"] = effects[e]/2
	for(var/e in matrix)
		if(prob(30))
			matrix[e] = 255-matrix[e]
	return matrix