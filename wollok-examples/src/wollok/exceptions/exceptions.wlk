import exceptionsLib.*

program exceptions {
val a = new A()

var i = 0
try {
	a.m1()
	this.println("No exception raised")
}
catch e : MyException
	e.printStackTrace()

then always
	i = i + 1

if (i > 0) {
	this.println("i is positive")
}
else {
	this.println("i is zero !")
}
	

this.println("End of program")

}