
#define TOXICITY_LIMIT 10
#define BURN_LIMIT 5
#define PIERCE_LIMIT 5
#define PAIN_LIMIT 5
#define STAMINA_LIMIT 5
#define DENSITY_LIMIT 15
#define MAX_RADIUS 5

/*
	Lost Worlds Chemistry Lesson:
	All chemicals are defined by an effect matrix, a list of attributes and values from 0 to 255.
	Effects get more powerful as they approach 128.
	There are a couple special effects:
	- Volatility is defined by the average of two effects and current generation.

	- Radioactivity only occurs if Radioactive is above 0.5, at which point the
	strength is Radioactive and the radius is RARadius.

	- Catalysis works only if it's above 0.7, and causes the chemical to become a catalyst,
	making other reactions yield new results if present. It cannot be reacted anymore and is the end of its line.

	- Unusual is a special number that causes the chemical to undergo specific transformations if it falls within
	a defined range of values. For example, 25-30% Unusual causes the chemical to become a liquid regardless of density.
*/
var/chem_descriptions/chem = new
chem_descriptions
	var/list
		a_aqueous = list("Clear","Flowing","Pure","Crystalline","Cloudy","Swirling")
		a_mercuric = list("Oily","Dark","Metallic","Slippery","Neon","Viscous")
		a_saline = list("Rough","Powdery","Refractive","Chunky","Cloudy","Intense")

		c_aqueous = list("Blue","Teal","Lime","Green","Turquoise","Transparent","Indigo")
		c_mercuric = list("Silver","Yellow","Brown","Grey","Golden","White","Maroon")
		c_saline = list("Orange","Red","Purple","Pink","Transparent","Golden","Violet","Teal")

		solids = list("Metal", "Salt", "Crystal", "Solid", "Gem", "Powder", "Substance")
		liquids = list("Salve","Tonic","Fluid","Lotion", "Syrup", "Elixir", "Liquid")
		gases = list("Vapour", "Gas", "Smoke", "Mist", "Fog")

		traits_aqueous = list("Toxicity","Pierce","Acidity","Stamina","Slippery")
		traits_mercuric = list("Density","Catalysis","Radioactive","Hardness","Conductivity")
		traits_saline = list("Volatility","Pain","Burn","Flammable","Corrupt")

		desc_table
		name_table

	New()
		LoadChemicals()
	Del()
		SaveChemicals()
		. = ..()
	proc
		SaveChemicals()
			var
				nt = assoc2text(name_table,"\n")
				dt = assoc2text(desc_table,"\n")
			fdel("Save/ChemTable.txt")
			text2file(nt+"\n---\n"+dt,"Save/ChemTable.txt")
			world.log << "Saved Chemicals."
		LoadChemicals()
			if(fexists("Save/ChemTable.txt"))
				var
					flist = dd_file2list("Save/ChemTable.txt","\n---\n")
					nt = flist[1]
					dt = flist[2]
				name_table = text2assoc(nt,"\n")
				desc_table = text2assoc(dt,"\n")
				world.log << "Loaded Chemicals."
			else
				desc_table = list()
				name_table = list()
				world.log << "Initialized Tables."


		assoc2text(list/L,separator=";",a_separator="=")
			var/list/M = list()
			for(var/entry in L)
				if(isnum(entry)) continue
				if(L[entry])
					M += "[entry][a_separator][L[entry]]"
				else if(entry)
					M += "[entry]"
			. = dd_list2text(M,separator)

		text2assoc(text,separator=";",a_separator="=")
			var/list/M = dd_text2list(text,separator)
			. = list()
			for(var/entry in M)
				var/a_loc = findtext(entry,a_separator)
				if(a_loc)
					var
						key = copytext(entry,1,a_loc)
						value = copytext(entry,a_loc+length(a_separator))
					. += key
					.[key] = value
				else if(entry)
					. += entry

var/list/base_matrix = list(
		"Toxicity" = 0,
		"Acidity" = 0,
		"Magnetism" = 0,
		"VolatilityA" = 0,
		"Pain" = 0,
		"Hardness" = 0,
		"Stamina" = 0,
		"Slippery" = 0,
		"Catalysis" = 0,
		"Density" = 0,
		"Burn" = 0,
		"Conductivity" = 0,
		"Pierce" = 0,
		"Radioactive" = 0,
		"RARadius" = 0,
		"VolatilityB" = 0,
		"Flammable" = 0,
		"Corrupt" = 0,
		"Unusual" = 0
		)
chemical
	var
		name
		r_name
		desc

		color
		state
		appearance
		primary_character
		secondary_character

		mass = 1
		generation = 0

		spectrum

		list/matrix

	proc
		Ratio(v)
			var/ratio = 1 - abs((matrix[v] - 128) / 128)
			return ratio
		DoubleRatio(v)
			var/ratio = rsin((matrix[v]*PI)/128)
			return ratio
		SigRatio(v)
			var/ratio = Ratio(v)
			return (ratio > 0.15 ? ratio : 0)
		CharacterValue(v)
			switch(v)
				if("Toxicity","Burn","Pierce","Pain","Stamina") return abs(DoubleRatio(v)*100)
				if("Volatility") return Volatility()*100
				if("Radioactive") return Radioactivity()*60
				if("Catalysis") return abs(Catalysis())*40
				else return Ratio(v)*100
		Toxicity()
			var/amt = DoubleRatio("Toxicity") * TOXICITY_LIMIT
			if(amt < 0) amt = amt * 0.6 * (Unusual(60,65)?2.5:1)
			else amt = amt * (Unusual(65,75)?2:1)
			return amt
		Burn()
			var/amt = DoubleRatio("Burn") * BURN_LIMIT
			if(amt < 0) amt = amt * 0.6 * (Unusual(75,80)?2.5:1)
			else amt = amt * (Unusual(80,90)?2:1)
			return amt
		Pierce()
			var/amt = DoubleRatio("Pierce") * PIERCE_LIMIT
			if(amt < 0) amt = amt * 0.6 * (Unusual(55,60)?2.5:1)
			return amt
		Acidity()
			return SigRatio("Acidity")
		Volatility()
			return (Ratio("VolatilityA") + Ratio("VolatilityB") + GenerationPenalty()) / 2
		Pain()
			var/amt = DoubleRatio("Pain") * PAIN_LIMIT
			if(amt < 0) amt = amt * 0.7
			else amt = amt * (Unusual(70,78)?2.5:1)
			return amt
		Stamina()
			var/amt = DoubleRatio("Stamina") * STAMINA_LIMIT
			if(amt > 0) amt = amt * 0.7
			else amt = amt * (Unusual(61,70)?2.5:1)
			return amt
		Slippery()
			return SigRatio("Slippery") * 100
		Flammable()
			return Ratio("Flammable") * 100
		Catalysis()
			/*
			Above 90%: 3 shifts
			Above 80%: 2 shifts
			Above 70%: 1 shift
			Shift direction determined by below/above 128.
			*/
			var/ratio = -abs((matrix["Catalysis"] - 128) / 128)+1
			var/sign
			if(matrix["Catalysis"] < 128) sign = -1
			else sign = 1

			if(ratio > 0.95) return 3 * sign
			else if(ratio > 0.9) return 2 * sign
			else if(ratio > 0.8) return 1 * sign
			else return 0
		Density()
			return max(0.5,Ratio("Density") * DENSITY_LIMIT)

		Volume()
			return mass / Density()

		Radioactivity()
			if(Ratio("Radioactive") > 0.6)
				return round(Ratio("RARadius") * MAX_RADIUS,0.5)
			else
				return 0

		Hardness()
			return Ratio("Hardness") * 100
		Conductivity()
			return Ratio("Conductivity") * 100
		Corruption()
			return Ratio("Corrupt") * 100

		Magnetism()
			return Ratio("Magnetism") * 25

		Unusual(a,b)
			return (matrix["Unusual"]/2.55 >= a) && (matrix["Unusual"]/2.55 < b)

		GenerationPenalty()
			return generation / 10

		SplitVolume(n)
			var/new_mass = n * Density()
			if(mass > new_mass)
				mass -= new_mass
				return new/chemical(new_mass,src,matrix)
			else return src
		SplitMass(n)
			var/new_mass = n
			if(mass > new_mass)
				mass -= new_mass
				return new/chemical(new_mass,src,matrix)
			else return src

		DebugWindow()
			var/window = {"<center>[name] ([state])</center><hr>
			Characters: [primary_character], [secondary_character]
			<hr>
			Density: [num2text(Density(),3)] - [matrix["Density"]]<br>
			Mass: [num2text(mass,3)]<br>
			Volume:[num2text(Volume(),3)]<br>
			Hardness: [num2text(Hardness(),3)] - [matrix["Hardness"]]<br>
			Conductivity: [num2text(Conductivity(),3)] - [matrix["Conductivity"]]<br>
			Magnetism: [num2text(Magnetism(),3)] - [matrix["Magnetism"]]
			<hr>
			Toxicity: [num2text(Toxicity(),3)] - [matrix["Toxicity"]]<br>
			Burn: [num2text(Burn(),3)] - [matrix["Butn"]]<br>
			Pierce: [num2text(Pierce(),3)] - [matrix["Pierce"]]<br>
			Acidity: [num2text(Acidity(),3)] - [matrix["Acidity"]]<br>
			Volatility: [num2text(Volatility(),3)] - [matrix["VolatilityA"]]/[matrix["VolatilityB"]]<br>
			Pain: [num2text(Pain(),3)] - [matrix["Pain"]]<br>
			Stamina: [num2text(Stamina(),3)] - [matrix["Stamina"]]<br>
			Slippery: [num2text(Slippery(),3)] - [matrix["Slippery"]]<br>
			Flammable: [num2text(Flammable(),3)] - [matrix["Flammable"]]<br>
			Catalysis: [Catalysis()] - [matrix["Catalysis"]]<br>
			Radioactivity: [Radioactivity()] - [matrix["Radioactive"]]/[matrix["RARadius"]]<br>
			Corruption: [Corruption()] - [matrix["Corruption"]]
			<hr>
			Unusual: [num2text(matrix["Unusual"]/2.55,2)] - [matrix["Unusual"]]<br>"}
			if(Unusual(15,20)) window += "Unusually Solid<br>"
			if(Unusual(20,25)) window += "Unusually Liquid<br>"
			window += "<hr>"
			return window

		GetParameters()
			dbg("[type]")
			GetCharacters()
			//dbg("Characters: [primary_character], [secondary_character]")
			GetState()
			//dbg("State: [state]")
			LoadName()
			if(!name)
				GetName()
				//dbg("Created: [name]")
			else
				//dbg("Loaded: [name]")

		GetCharacters()
			var/aqueous = 0
			var/mercuric = 0
			var/saline = 0
			for(var/v in matrix)
				if(v in chem.traits_aqueous)
					aqueous += CharacterValue(v)
				if(v in chem.traits_mercuric)
					mercuric += CharacterValue(v)
				if(v in chem.traits_saline)
					saline += CharacterValue(v)

			var
				minCharacter = min(aqueous,mercuric,saline)
				primary
				secondary

			if(minCharacter == aqueous)
				primary = mercuric
				secondary = saline
			if(minCharacter == saline)
				primary = aqueous
				secondary = mercuric
			if(minCharacter == mercuric)
				primary = aqueous
				secondary = saline

			if(primary < secondary)
				var/temp = secondary
				secondary = primary
				primary = temp

			if(primary == aqueous) primary_character = "Aqueous"
			if(primary == saline) primary_character = "Saline"
			if(primary == mercuric) primary_character = "Mercuric"
			if(secondary == aqueous) secondary_character = "Aqueous"
			if(secondary == saline) secondary_character = "Saline"
			if(secondary == mercuric) secondary_character = "Mercuric"

		GetState()
			var/density = Density()
			if(density < 3) state = "Gas"
			else if(density < 8) state = "Liquid"
			else state = "Solid"
			if(Unusual(15,20)) state = "Solid"
			if(Unusual(20,25)) state = "Liquid"

		LoadName()
			if(name) return //Pre-made chemical.
			//world.log << "CHEM: Searching tables..."
			for(var/v in chem.desc_table)
				//world.log << "START [v] = [chem.desc_table[v]] END"
				if(v == spectrum)
					//world.log << "Acquired description: [chem.desc_table[v]]"
					name = chem.desc_table[v]
					var/splitA = findtext(name, " ")
					var/splitB = findtext(name, " ", splitA+1)
					color = copytext(name,splitA+1,splitB)
					appearance = copytext(name,splitB+1)
					break
			if(name)
				for(var/v in chem.name_table)
					if(v == name)
						r_name = chem.name_table[v]
						var/split = findtext(r_name, "|")
						desc = copytext(r_name,split+1)
						r_name = copytext(r_name,1,split)
						break

		GetName()
			var/list/adj_list
			var/list/color_list
			var/list/state_list

			var/choice = rand(1,6)
			if(choice <= 3) adj_list = chem.vars["a_[lowertext(primary_character)]"]
			else if(choice <= 5) adj_list = chem.vars["a_[lowertext(secondary_character)]"]
			else adj_list = chem.vars["a_[pick("aqueous","saline","mercuric")]"]

			choice = rand(1,6)
			if(choice <= 3) color_list = chem.vars["c_[lowertext(primary_character)]"]
			else if(choice <= 5) color_list = chem.vars["c_[lowertext(secondary_character)]"]
			else color_list = chem.vars["c_[pick("aqueous","saline","mercuric")]"]

			switch(state)
				if("Gas")
					state_list = chem.gases
				if("Liquid")
					state_list = chem.liquids
				else
					state_list = chem.solids

			color = pick(color_list)
			appearance = pick(state_list)
			name = "[pick(adj_list)] [color] [appearance]"

			//Make sure the name is unique.
			for(var/s in chem.desc_table)
				if(name == chem.desc_table[s]) return GetName()

			chem.desc_table.Add(spectrum)
			chem.desc_table[spectrum] = name

	New(mass=1,gen=0,new_matrix=null)
		//dbg("Making a new chemical")
		if(new_matrix)
			matrix = new_matrix
		else
			var/matrix_mods = matrix
			matrix = base_matrix.Copy()
			for(var/v in matrix_mods)
				matrix[v] = matrix_mods[v]

		src.mass = mass
		if(istype(gen,/chemical))
			var/chemical/base = gen
			name = base.name
			r_name = base.r_name
			desc = base.desc
			generation = base.generation

			color = base.color
			state = base.state
			appearance = base.appearance
			primary_character = base.primary_character
			secondary_character = base.secondary_character
			spectrum = base.spectrum
		else
			generation = gen

			spectrum = matrix2text(matrix)
			GetParameters()