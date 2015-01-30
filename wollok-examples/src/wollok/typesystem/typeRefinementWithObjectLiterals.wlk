program typeRefinementWithObjectLiterals {

	var a = object {         // type = { m1 ; m3 }
		method m1() { }
		method m3() { }
	}
	
	a = object {          // type = { m1 ; m2 }
		method m1() { }
		method m2() { }
	}
	
	// a type = { m1 } (common type)
	
	a.m1()  //FINE !
}