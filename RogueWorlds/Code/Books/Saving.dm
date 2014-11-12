book_save
	New(item/writing/page/book/B)
		if(istype(B))
			title = B.title
			pages = B.pages
			while(!isturf(B))
				B = B.loc
			x = B.x
			y = B.y
			z = B.z
	var
		title
		list/pages
		x
		y
		z

	proc/Load(item/writing/page/book/B)
		B.title = title
		B.pages = pages
		var/ship/bookshelf/S = locate() in B.loc
		if(S)
			B.loc = S
		B.UpdateStacks()

page_save
	New(item/writing/page/P)
		written = P.written
		anchored = P.isAnchored
		px = P.pixel_x
		py = P.pixel_y
		while(!isturf(P))
			P = P.loc
		x = P.x
		y = P.y
		z = P.z
	var
		written
		anchored
		px
		py
		x
		y
		z

	proc/Load(item/writing/page/B)
		B.written = written
		B.isAnchored = anchored
		B.pixel_x = px
		B.pixel_y = py
		B.UpdateStacks()
proc
	SaveBooks()
		if(fexists("Save/Books.sav"))
			fdel("Save/Books.sav")
		var/savefile/F = new("Save/Books.sav")
		var/books = 0
		var/pages = 0
		for(var/item/writing/page/P)
			if(P.printed) continue // Premade paper and books will appear when the map loads next round.
			if(istype(P,/item/writing/page/book))
				if(P:title || P:pages:len > 1 || P:pages[1])
					books++
					F["books"] << new /book_save(P)
			else
				if(P.written)
					pages++
					F["pages"] << new /page_save(P)
		F << books
		F << pages
		del F
	LoadBooks()
		if(!fexists("Save/Books.sav")) return
		var/savefile/F = new("Save/Books.sav")
		var
			books
			pages
		F >> books
		F >> pages
		var/book_save/B
		var/page_save/P
		for(var/i = 1, i <= books, i++)
			F["books"] >> B
			B.Load(new/item/writing/page/book(locate(B.x,B.y,B.z)))
		for(var/i = 1, i <= pages, i++)
			F["pages"] >> P
			P.Load(new/item/writing/page(locate(P.x,P.y,P.z)))
		del F