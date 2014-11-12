item/writing/page/book
	name = "Book"
	weight = 5
	icon = 'Icons/Books/Book.dmi'
	var/title = ""
	var/open_to_page = 0
	var/list/pages = list("")
	interfaceName = "pagecover"

	UpdateStacks()
		if(!title) return ..()
		else name = title

	ExaminedBy(mob/M)
		if(pages.len > 1 || pages[1])
			OpenPage(M)
		else return ..()

	OpenPage(mob/M, writing)
		src.writing_with = writing
		M.OpenInterface(src)
		SetupPage(M)
		var/read_only = 0
		if(get_dist(src,M) > 1 && loc != M)
			read_only = 1
			winset(M,"page.PageLeft","is-visible=false")
			winset(M,"page.PageRight","is-visible=false")
			winset(M,"pagecover.PageRight","is-visible=false")
		while(M.client && M.interfacing_with == src)
			sleep(5)
			if(!read_only)
				UpdateInk(M)
			if(writing_with)
				if(writing_with.loc != M && get_dist(M,writing_with) > 1)
					writing_with = null
					SetupPage(M)
			if(!read_only && (src.loc != M && get_dist(M,src) > 1))
				read_only = 1
				winset(M,"page.PageLeft","is-visible=false")
				winset(M,"page.PageRight","is-visible=false")
				winset(M,"pagecover.PageRight","is-visible=false")
			else if(read_only && (get_dist(M,src) <= 1 || loc == M))
				read_only = 0
				winset(M,"page.PageLeft","is-visible=true")
				winset(M,"page.PageRight","is-visible=true")
				winset(M,"pagecover.PageRight","is-visible=true")
				SetupPage(M)
		ClosePage(M)
		writing_with = null

	InterfaceBy(mob/M,cmd)
		switch(cmd)
			if("Forward")
				ClosePage(M)
				if(!open_to_page)
					winshow(M,"pagecover",0)
					winshow(M,"page",1)
				open_to_page++
				icon_state = "open"
				interfaceName = "page"
				SetupPage(M)
			if("Back")
				ClosePage(M)
				open_to_page--
				if(!open_to_page)
					winshow(M,"page",0)
					winshow(M,"pagecover",1)
					icon_state = null
					interfaceName = "pagecover"
				SetupPage(M)

	SetupPage(mob/M)
		if(!M.client) return
		if(open_to_page)
			winset(M,"page.PageLeft","is-visible=true")
			winset(M,"page.WriteText","text=\"[GetPage()]\"")
			if(writing_with)
				winset(M,"page.WriteText","is-visible=true")
				winset(M,"page.PageRight","is-visible=true")
			else
				winset(M,"page.ReadText","text=\"[GetPage()]\"")
				winset(M,"page.WriteText","is-visible=false")
				if(open_to_page == pages.len) winset(M,"page.PageRight","is-visible=false")
				else winset(M,"page.PageRight","is-visible=true")
			winset(M,"page.Number","text=\"[open_to_page]\"")
			winset(M,"page.Title","text=\"[title]\"")
		else
			winset(M,"pagecover.WriteTitle","text=\"[title]\"")
			if(writing_with)
				winset(M,"pagecover.WriteTitle","is-visible=true")
			else
				winset(M,"pagecover.ReadTitle","text=\"[title]\"")
				winset(M,"pagecover.WriteTitle","is-visible=false")

	ClosePage(mob/M)
		if(!M.client) return
		if(open_to_page)
			if(writing_with)
				var/new_text = winget(M,"page.WriteText","text")
				if(new_text)
					while(open_to_page > pages.len)
						pages += ""
					pages[open_to_page] = new_text
					M.VisualMessage("[M] writes something down on paper.")
		else
			if(writing_with)
				var/new_text = winget(M,"pagecover.WriteTitle","text")
				if(new_text)
					title = new_text
					M.VisualMessage("[M] writes something down on paper.")
				UpdateStacks()

	proc/GetPage()
		if(open_to_page > pages.len) return ""
		else return pages[open_to_page]