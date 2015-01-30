program tomYJerry {
	
	val tom = object {
		var energia = 100
		var posicion = 0
		method getVelocidad() {
			5 + energia / 10
		}
		method puedeAtraparA(raton) {
			this.getVelocidad() > raton.getVelocidad()
		}
		method correA(raton) {
			var distancia = raton.getPosicion() - posicion
			energia -= 0.5 * this.getVelocidad() * distancia
			posicion = raton.getPosicion()
		}
		method comeA(raton) {
			this.correA(raton)
			energia += 12 + raton.getPeso()
		}
	}
	
	val jerry = object {
		var peso = 10
		var posicion = 10
		method getVelocidad() {
			10 - peso
		}
		method getPosicion() {
			posicion
		}
		method getPeso() {
			peso
		}
	}
	
	this.assert(tom.puedeAtraparA(jerry))
	tom.correA(jerry)

	tom.comeA(jerry)
}