proc
	matrix2text(list/matrix)
		. = ""
		for(var/v in matrix)
			var/n = matrix[v]
			. += sd_dec2base(round(n/16,1),16)

	offset_list(list/L,n)
		if(n == 0) return L
		else if(n > 0)
			//Move n elements from end to start.
			return L.Copy(L.len-n) + L.Copy(1,L.len-n)
		else
			//Move -n elements from start to end.
			return L.Copy(-n) + L.Copy(1,-n)

	matrix_add2(list/A, list/B, offset = 0)
		B = offset_list(B,offset)
		. = base_matrix.Copy()
		for(var/v = 1 to A.len)
			.[.[v]] = (A[A[v]]*2 + B[B[v]]*2)%256

	matrix_multiply(list/A, list/B, offset = 0)
		B = offset_list(B,offset)
		. = base_matrix.Copy()
		for(var/v = 1 to A.len)
			.[.[v]] = (A[A[v]] * B[B[v]])%256

	matrix_xor(list/A, list/B, offset = 0)
		B = offset_list(B,offset)
		. = base_matrix.Copy()
		for(var/v = 1 to A.len)
			.[.[v]] = (A[A[v]] ^ B[B[v]])%256

	rsin(x)
		return sin(x*(180/PI))
	/*findlast(haystack,needle)
		var/i = length(haystack)+1-needle.len
		while(i >= 0)
			if(copytext(haystack,i,i+needle.len) == needle) return i
			i--
		return 0*/

proc/MixChemicals(chemical/A, chemical/B, operation=MAT_ADD, offset)
	dbg("Doing math and shit...")
	var/list/new_matrix

	switch(operation)
		if(MAT_ADD)
			new_matrix = matrix_add2(A.matrix,B.matrix,offset)
		if(MAT_MUL)
			new_matrix = matrix_multiply(A.matrix,B.matrix,offset)
		if(MAT_XOR)
			new_matrix = matrix_xor(A.matrix,B.matrix,offset)
		else
			CRASH("Unknown operation applied to chemicals: [operation]")

	//Chemical C has combined mass of both chemicals, and the highest generation + 1
	dbg("New Matrix:")
	for(var/v in new_matrix)
		dbg("[v]-[new_matrix[v]]")
	var/chemical/C = new(A.mass+B.mass, max(A.generation,B.generation)+1, new_matrix)
	dbg("Made a chemical: [C]")
	return C