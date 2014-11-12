proc
	pyth(a,b) return sqrt(a*a+b*b)
	arcpyth(a,c) return sqrt(c*c-a*a)
	triarea(a,b,C) return (a*b*sin(C))/2
	tan(n) return sin(n)/cos(n)
	cot(n) return cos(n)/sin(n)
	sec(n) return 1/cos(n)
	csc(n) return 1/sin(n)
	arctan(n) return arccos(1/sqrt(1+n*n))
	arccot(n) return arcsin(1/sqrt(1+n*n))
	arcsec(n) return arccos(1/n)
	arccsc(n) return arcsin(1/n)
	arctan2(x,y)
		var/division = sqrt(x*x+y*y)+x
		if(division == 0) division = 0.0001
		return 2*arctan(y/division)