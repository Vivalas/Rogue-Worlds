material
	var
		name = "Unknown Material"
		desc = "Unknown" //An adjective used in material prefixes.
		flammability = 0
		fireFuel = 0
		bulletResistance = 1
		conductivity = 0
		temp = 0
		object_name = "" //Stores the original name of the object it applies to, before material prefixes were applied.

	New(atom/A)
		ASSERT(!A || istype(A,/atom))
		if(A)
			object_name = A.name

	//Materials which can turn to liquid if heated.
	meltable
		var
			meltingTemp = 0
			isLiquid = 0

		//Metals
		metal
	iron
		parent_type = /material/meltable/metal
		name = "Iron"
		desc = "Iron"
		meltingTemp = 1000
		bulletResistance = 3

	brass
		parent_type = /material/meltable/metal
		name = "Brass"
		desc = "Brass"
		meltingTemp = 650
		bulletResistance = 2

	gold
		parent_type = /material/meltable/metal
		meltingTemp = 200
		name = "Gold"
		desc = "Gold"
		bulletResistance = 4

	glass
		name = "Glass"
		desc = "Glass"
		bulletResistance = 0.5

	wood
		name = "Wood"
		desc = "Wooden"

	cloth
		name = "Cloth"
		desc = "Cloth"
		bulletResistance = 0