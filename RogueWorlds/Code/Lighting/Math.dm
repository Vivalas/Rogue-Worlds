proc/get_square_dist(Ax,Ay,Az,Bx,By,Bz)
	var/X = (Ax - Bx)
	var/Y = (Ay - By)
	var/Z = (Az - Bz)
	return (X * X + Y * Y + Z * Z)

proc/nsqrt(n)
	if(n <= 0) return 0
	var/x = n
	var/oldx = x + 250
	while(abs(x - oldx) > 1)
		oldx = x
		x = (x+(n/x))/2
	return x