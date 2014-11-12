var/list/round_ports = list()
var/list/port_names = list("Port Collins","Port Morgan","Port Lauderdale","Port McKinley","Port BLUH")
var/list/cargo_items = list(/item/cargo/gold_vase = 15, /item/cargo/gold_coins = 1)

proc/GeneratePorts(n = 4)
	for(var/i = 1, i <= n, i++)
		new/port()

	//for(var/port/P in round_ports)
	//	if(P.port_number < round_ports.len)
	//		for(var/c = rand(3,5), c > 0, c--)
	//			P.GenerateCargo()

port
	var
		name = "Port"
		port_number = 1
		list/cargo_outgoing = list()
		list/cargo_expected = list()

	New()
		port_number = round_ports.len+1
		name = pick(port_names)
		port_names -= name
		round_ports.Add(src)

	proc/Debug()
		world << "<b><u>[name]</b></u>"
		world << "Port #[port_number]"
		world << "<b>Outgoing: </b>"
		for(var/i = 1, i <= cargo_outgoing.len, i++)
			var/ship/box/B = cargo_outgoing[i]
			world << "Box #[i] shipping to [cargo_outgoing[B]]"
			for(var/item/I in B)
				world << " - [I]"


	proc/GenerateCargo()
		var/total_value = rand(10,25)
		var/ship/box/shipping_box = new(null)
		var/list/treasures = list()
		while(total_value > 0)
			var/itemid = 1
			var/cargo_type = cargo_items[itemid]

			//Find the largest item smaller than or equal to the total value of the treasure.
			while((cargo_items[cargo_type] > total_value || prob(10)) && itemid < cargo_items.len)
				itemid++
				cargo_type = cargo_items[itemid]

			//Find an existing treasure with less than its maximum stack size.
			var/item/treasure
			for(var/item/I in treasures)
				if(I.type == cargo_type && I.stack_size < I.max_stack_size)
					treasure = I

			//Either this is unstackable or every other stack is full. Make a new treasure item.
			if(!treasure)
				var/item/I = new cargo_type(shipping_box)
				I.stack_size = 1
				I.UpdateStacks()
				treasures.Add(I)
			else
				treasure.stack_size++
				treasure.UpdateStacks()

			//Subtract the value of the treasure from the remaining value.
			total_value -= cargo_items[cargo_type]

		var/port/destination = round_ports[rand(port_number+1, round_ports.len)]
		destination.cargo_expected += treasures

		cargo_outgoing += shipping_box
		cargo_outgoing[shipping_box] = destination