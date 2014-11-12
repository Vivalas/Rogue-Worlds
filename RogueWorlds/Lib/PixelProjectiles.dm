/******************************************************************
Pixel Projectiles
By Shadowdarke (shadowdarke@hotmail.com) May 2005
Commissioned by DaGoat787

Pixel Projectiles provides a simple interface for customizable
directional projectiles that can fire at any angle, speed, and
duration between updates.

HOW TO USE PIXEL PROJECTILES:
You launch a pixel projectile with the FirePixelProjectile()
proc. It's format is as follows:

FirePixelProjectile(owner, destination, proj_type)
ARGS:
	owner (atom)	- The atom that launched the projectile, also
						the start point of its trajectory.
	destination		- destination may be an angle in degrees, or
						an atom that the projectile is launched
						towards.
	proj_type		- The type of projectile. This should be a
						type of /obj/sd_px_projectile.
						DEFAULT: proj_type = /obj/sd_px_projectile

RETURNS: The projectile launched, if it is still active.

/obj/sd_px_projectile is designed so that you may define your own
subtypes with unique properties. The values and procs that you may
override are described below.

obj/sd_px_projectile
	VARS
		range	- The number of cycles this projectile will fly
					DEFAULT: range = 7
		speed	- Pixel distance that the projectile moves per cycle
					DEFAULT: speed = 32
		delay	- Number of ticks between update cycles
					DEFAULT: delay = 1
		cx		- Starting/current pixel_x
					DEFAULT: cx = 16
		cy		- Starting/current pixel_y
					DEFAULT: cx = 16
	PROCS
		CheckHit(turf/T)
			Searches T to see if the projectile hit anything there.
			ARGS: T	- turf to check for a hit
			RETURNS: The atom hit or null if no atom in the turf is
				hit.
			DEFAULT: returns T if it is dense, the first dense
				item in T, or null if there are no dense atoms in
				the turf.

		Hit(atom/A)
			Called when the projectile hits atom A
			ARGS: A	- The atom that the projectile hit
			DEFAULT: Reports the hit to the world. You should
				override this proc to reflect what you want to
				happen when this projectile hits something.

				IMPORTANT: Hit() should ALWAYS end by deleting
				the projectile i.e. "del(src)".

		Terminate()
			Called when the projectile reaches the end of its range
			without hitting anything
			DEFAULT: Delete the projectile

The other vars and procs of /obj/sd_px_projectile should not be
tampered with under normal circumstances.

Pixel Projectiles are not intended to be saved. Ideally, your
saving routines should not sned an sd_px_projectile obj to a
savefile. If they are accidentally saved, sd_px_projectiles
automatically delete themselves shortly after loading.

HOW TO MAKE SPREAD SHOTS:
Pixel Projectiles provides the FireSpread() proc for easy spread shots.

FireSpread(owner, destination, proj_type, pellets, spread)
ARGS:
	owner (atom)	- The atom that launched the projectile, also
						the start point of its trajectory.
	destination		- destination may be an angle in degrees, or
						an atom that the projectile is launched
						towards.
	proj_type		- The type of projectile. This should be a
						type of /obj/sd_px_projectile.
						DEFAULT: proj_type = /obj/sd_px_projectile
	pellets			- The number of pellets in this spread shot
						DEFAULT: pellets = 1
	spread			- the maximum angle that each pellet can deviate
						from the base angle. If spread is negative
						then the pellets have random trajectories
						within the range, if it is positive, then
						the pellets are evenly spread to fill the
						entire range.
						DEFAULT: spread = 0

Note: You can allow a margin of error for single shots by calling
FireSpread() with 1 pellet and a negative spread. ;)

******************************************************************/

proc/FirePixelProjectile(atom/owner, destination, proj_type = \
	/obj/sd_px_projectile)
	/* fires a pixel based projectile of type proj_type from owner to
		destination. Destination may be a turf or angle of fire. */
	if(!owner) return
	var/obj/sd_px_projectile/P = new proj_type()
	P.owner = owner
	P.loc = P.TurfOf(owner)
	P.pixel_x = P.cx
	P.pixel_y = P.cy

	if(isnum(destination))	// an angle
		P.dx = cos(destination) * P.speed
		P.dy = sin(destination) * P.speed

	else if(istype(destination, /atom))
		var
			atom/A = destination
			dx = (A.x - owner.x) * 32 + A.pixel_x - owner.pixel_x
			dy = (A.y - owner.y) * 32 + A.pixel_y - owner.pixel_y
			px_dist = sqrt(dx * dx + dy * dy)
		if(px_dist)	// unit vector times P.speed
			P.dx = P.speed * dx / px_dist
			P.dy = P.speed * dy / px_dist
		else	// owner and target in exact same position
			P.Hit(A)
			return P

	else
		world.log << "Invalid destination: FirePixelProjectile([owner], [destination], \
			[proj_type])"
		del(P)
		return

	if(P)
		spawn(P.delay)	// so this proc can return normally
			while(P)
				P.UpdatePosition()
				//if(P && (alert("[P.x]:[P.cx], [P.y]:[P.cy]",,"Ok", "Delete")=="Delete"))
				//	del(P)
				if(P) sleep(P.delay)

	return P

proc/FireSpread(atom/owner, destination, proj_type = \
	/obj/sd_px_projectile, pellets = 1, spread = 0)
	var/base_angle
	if(isnum(destination))
		base_angle = destination
	else if(istype(destination,/atom))
		var
			atom/A = destination
			dx = (A.x - owner.x) * 32 + A.pixel_x - owner.pixel_x
			dy = (A.y - owner.y) * 32 + A.pixel_y - owner.pixel_y

		// Arctan courtesy of Lummox JR
		if(!dx && !dy) base_angle = 0    // the only special case
		else
			var/a=arccos(dx/sqrt(dx*dx+dy*dy))
			base_angle = (dy>=0)?(a):(-a)

	if(spread<=0)	// random spread
		for(var/loop = 1 to pellets)
			FirePixelProjectile(owner, base_angle + rand(spread, -spread), proj_type)
	else if(pellets>1)	// uniform spread
		var/d_angle = spread*2/(pellets-1)
		base_angle -= spread
		for(var/loop = 0 to pellets - 1)
			FirePixelProjectile(owner, base_angle + loop * d_angle, proj_type)
	else
		FirePixelProjectile(owner, base_angle, proj_type)

obj/sd_px_projectile
	layer = FLY_LAYER
	animate_movement = NO_STEPS
	var/tmp
		range = 7	// number of cycles this projectile will fly
		speed = 32	// px per update cycle
		delay = 1	// ticks between updates
		cx = 16	// starting/current pixel_x
		cy = 16	// starting/current pixel_y

		////////////////////////////////////////////////////////
		// INTERNAL VARS: You shouldn't mess with the vars below
		////////////////////////////////////////////////////////
		dx	// change in cx per update cycle (derived from speed)
		dy	// change in cy per update cycle (derived from speed)
		owner	// who/what the projectile belongs to
		same_turf = 1	// cleared when proj leaves start turf

	Read()
		// somehow ended up saved to a file. delete it
		. = ..()
		spawn(2) del(src)

	proc
		CheckHit(turf/T)
			if(!T) return
			if(T.density)
				return T
			for(var/atom/A in T)
				if(A.density)
					if((A == owner) && (same_turf))
						// don't hit the owner in the first tick
						continue
					return A

		dist(atom/A)
			// returns the square of the pixel distance between src and A
			if(!istype(A)) return 0
			var/sx = (A.x - x) * 32 + A.pixel_x - pixel_x
			var/sy = (A.y - y) * 32 + A.pixel_y - pixel_y
			return sx * sx + sy * sy

		Hit(atom/A)
			// the projectile just hit A
			// Override to fit into your program
			world << "[owner]'s [src] hit [A] at ([A.x], [A.y])."

			// Hit() should ALWAYS end with the following line:
			del(src)

		Intercept()
			/* checks the path between current postion and new
				position
				RETURNS: the first dense blockage encountered or
					null */
			var
				n; d
				mx; my	// overall change
				sx; sy	// change per step
				offset
				turf/T
				atom
					N; M	// atoms encountered
			mx = dx/32
			my = dy/32

			if(mx)
				sx = sgn(mx)
				sy = my/mx * sx
				n = 0
				d = abs(mx)
				offset = pixel_y/32
				while(!N && (++n <= d))
					T = locate(round(x + sx * n), \
						round(y + offset + sy * n), z)
					if(!T) break
					N = CheckHit(T)

			if(N)
				d = dist(N)
			else
				d = abs(my)

			if(my)
				sy = sgn(my)
				sx = mx/my * sy
				n = 0
				offset = pixel_x/32
				while(!M && (++n <= d))
					T = locate(round(x + offset + sx * n), \
						round(y + sy * n), z)
					if(!T) break
					M = CheckHit(T)

			// return the closest of the two
			if(!M || N && (dist(N) < dist(M)))
				return N
			else
				return M

		sgn(n)
			if(n<0) return -1
			else if(n>0) return 1
			return 0

		Terminate()
			/* overide if you want the missile to do something
				if it reaches range without hitting something */
			del(src)

		TurfOf(atom/A)
			if(istype(A)) return locate(A.x, A.y, A.z)

		UpdatePosition()
			if(isturf(loc)) // in case anything new is in T
				var/H = CheckHit(loc)
				if(H) Hit(H)
			var/atom/A = Intercept()
			if(A) Hit(A)
			cx += dx
			while(cx >= 32)
				same_turf = 0
				cx -= 32
				if(++x > world.maxx)
					del(src)
			while(cx < 0)
				same_turf = 0
				cx += 32
				if(--x < 1)
					del(src)
			pixel_x = cx

			cy += dy
			while(cy >= 32)
				same_turf = 0
				cy -= 32
				if(++y > world.maxy)
					del(src)
			while(cy < 0)
				same_turf = 0
				cy += 32
				if(--y < 1)
					del(src)
			pixel_y = cy

			if(--range<=0)
				Terminate()