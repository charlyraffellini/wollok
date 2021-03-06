class Actividad {
	method calcularMejora()
}

class EstudiarMateria extends Actividad {
	var materia
	var puntos = 0
	
	new(m, p) {
		materia = m
		puntos = p
	}
	
	override method calcularMejora() { puntos }
}

class EjercitarEnSimulador extends Actividad {
	var horas = 0
	new(h) { horas = h }
	override method calcularMejora() { 10 * horas }
}