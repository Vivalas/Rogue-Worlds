#define TOXICITY(X)     "Toxicity" = (128-(X))
#define ACIDITY(X)      "Acidity" = (128-(X))
#define VOLATILITYA(X)  "VolatilityA" = (X)
#define PAIN(X)         "Pain" = (128-(X))
#define STAMINA(X)      "Stamina" = (128-(X))
#define SLIPPERY(X)     "Slippery" = (X)
#define CATALYSIS(X)    "Catalysis" = (X)
#define DENSITY(X)      "Density" = (X)
#define BURN(X)         "Burn" = (128-(X))
#define PIERCE(X)       "Pierce" = (128-(X))
#define RADIOACTIVE(X)  "Radioactive" = (X)
#define RARADIUS(X)     "RARadius" = (X)
#define VOLATILITYB(X)  "VolatilityB" = (X)
#define FLAMMABLE(X)    "Flammable" = (X)
#define UNUSUAL(X)      "Unusual" = (X)
#define CORRUPT(X)      "Corrupt" = (X)
#define HARDNESS(X)     "Hardness" = (X)
#define CONDUCTIVITY(X) "Conductivity" = (X)
#define MAGNETISM(X)   "Magnetism" = (X)

chemical
	antinine
		name = "Swirling Blue Gas"
		r_name = "Antinine"
		color = "blue"
		state = "gas"
		matrix = list(
		ACIDITY(-10),
		HARDNESS(253),
		VOLATILITYA(10),
		VOLATILITYB(15),
		DENSITY(3),
		CATALYSIS(225),
		FLAMMABLE(100),
		UNUSUAL(14)
		)
	galtinium
		name = "Metallic Green Crystal"
		r_name = "Galtinium"
		color = "green"
		state = "crystal"
		matrix = list(
		ACIDITY(5),
		HARDNESS(10),
		VOLATILITYA(10),
		DENSITY(120),
		CATALYSIS(10),
		BURN(20),
		FLAMMABLE(10),
		UNUSUAL(220),
		MAGNETISM(25)
		)
	oshotium
		name = "Shiny Black Substance"
		r_name = "Oshotium"
		color = "black"
		state = "substance"
		matrix = list(
		VOLATILITYA(30),
		DENSITY(180),
		HARDNESS(60),
		STAMINA(123),
		CATALYSIS(250),
		FLAMMABLE(180),
		VOLATILITYB(5),
		RADIOACTIVE(245),
		UNUSUAL(86)
		)
	norasper
		name = "Thick Orange Elixir"
		r_name = "Norasper"
		color = "orange"
		state = "liquid"
		matrix = list(
		ACIDITY(10),
		HARDNESS(7),
		DENSITY(170),
		PAIN(-10),
		SLIPPERY(75),
		UNUSUAL(62), //Keeps it in a liquid state.
		CONDUCTIVITY(228)
		)
	sarcanine
		name = "Clear Brown Liquid"
		r_name = "Sarcanine"
		color = "brown"
		state = "liquid"
		matrix = list(
		TOXICITY(25),
		DENSITY(40),
		HARDNESS(249),
		VOLATILITYA(50),
		STAMINA(-15),
		CATALYSIS(55),
		UNUSUAL(12),
		CORRUPT(25)
		)
	lenakohnium
		name = "Strange Purple Crystalloid"
		r_name = "Lenakohnium"
		color = "purple"
		state = "crystalloid"
		matrix = list(
		TOXICITY(-10),
		//"Toxicity" = 192,
		DENSITY(100),
		HARDNESS(70),
		PIERCE(50),
		ACIDITY(20),
		CATALYSIS(230),
		VOLATILITYB(20),
		RADIOACTIVE(110), //Doesn't do anything without RARadius
		CORRUPT(250)
		)
	rakulum
		name = "Chunky Golden Solid"
		r_name = "Rakulum"
		color = "golden"
		state = "solid"
		matrix = list(
		TOXICITY(50),
		DENSITY(80),
		HARDNESS(175),
		STAMINA(-30),
		ACIDITY(-40),
		PAIN(-10),
		CATALYSIS(45),
		FLAMMABLE(10),
		UNUSUAL(150),
		SLIPPERY(32),
		CORRUPT(5)
		)
	acoustiril
		name = "Cloudy Turquoise Vapour"
		r_name = "Acoustiril"
		color = "turquoise"
		state = "gas"
		matrix = list(
		TOXICITY(-10),
		VOLATILITYB(50),
		DENSITY(15),
		HARDNESS(10),
		STAMINA(5),
		CATALYSIS(15),
		FLAMMABLE(150),
		PIERCE(-10)
		)
	crysticite
		name = "Clear Teal Crystal"
		r_name = "Crysticite"
		color = "teal"
		state = "crystal"
		matrix = list(
		ACIDITY(20),
		DENSITY(180),
		HARDNESS(183),
		PAIN(5),
		CATALYSIS(1),
		UNUSUAL(30),
		VOLATILITYB(3),
		PIERCE(-65),
		SLIPPERY(100),
		MAGNETISM(48),
		CORRUPT(15),
		)
	heterogen
		name = "Intense Yellow Gas"
		r_name = "Heterogen"
		color = "yellow"
		state = "gas"
		matrix = list(
		TOXICITY(118),
		DENSITY(20),
		PAIN(25),
		CATALYSIS(75),
		UNUSUAL(250),
		VOLATILITYB(10),
		RARADIUS(20),
		CORRUPT(32),
		)

	phlosus
		name = "Strange Pink Substance"
		r_name = "Phlosus"
		color = "pink"
		state = "solid"
		matrix = list(
		"Toxicity" = 0,
		"Metabolic Speed" = 210,
		"VolatilityA" = 150,
		"Density" = 2,
		"HealPain" = 10,
		"StaminaGainA" = 10,
		"Catalysis" = 0,
		"Flammable" = 50,
		"VolatilityB" = 30,
		"HealPhys" = 0,
		"Radioactive" = 100,
		)
	berinium
		name = "Light Violet Vapour"
		r_name = "Berinium"
		color = "violet"
		state = "gas"
		matrix = list(
		TOXICITY(20),
		DENSITY(25),
		FLAMMABLE(50),
		SLIPPERY(150),
		CORRUPT(90)
		)
	astronine
		name = "Neon Silver Liquid"
		r_name = "Astronine"
		color = "silver"
		state = "liquid"
		matrix = list(
		"Toxicity" = 0,
		"Metabolic Speed" = 100,
		"VolatilityA" = 100,
		"Density" = 0,
		"Stamina" = 10,
		"Catalysis" = 120,
		"UnusedD" = 200,
		"Flammable" = 0,
		"HealPhys" = 20,
		"Slippery" = 200,
		"Radioactive" = 100,
		)
	nonus
		name = "Brilliant White Tonic"
		r_name = "Nonus"
		color = "white"
		state = "liquid"
		matrix = list(
		"Toxicity" = 170,
		"Metabolic Speed" = 15,
		"VolatilityA" = 100,
		"Density" = 200,
		"Catalysis" = 180,
		"UnusedD" = 15,
		"Flammable" = 0,
		"VolatilityB" = 120,
		"HealPhys" = 0,
		)
	primium
		name = "Odd Indigo Rock"
		r_name = "Primium"
		color = "indigo"
		state = "rock"
		matrix = list(
		"Toxicity" = 90,
		"VolatilityA" = 130,
		"Density" = 250,
		"Catalysis" = 50,
		"Flammable" = 0,
		"VolatilityB" = 10,
		"HealPhys" = 0,
		"Slippery" = 120,
		"Radioactive" = 100,
		)
	ultrine
		name = "Bizarre Colorless Material"
		r_name = "Ultrine"
		color = "colorless"
		state = "material"
		matrix = list(
		"Toxicity" = 0,
		"Metabolic Speed" = 5,
		"VolatilityA" = 200,
		"Density" = 255,
		"Catalysis" = 140,
		"Flammable" = 0,
		"VolatilityB" = 200,
		"HealPhys" = 0,
		"Radioactive" = 255,
		)