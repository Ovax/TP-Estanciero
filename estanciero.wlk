object tablero {
    var casilleros = new List()
    
    method casillerosDesde(casilleroInicial, unNumero) {
        var inicio = self.indiceDeCasillero(casilleroInicial)
        return (casilleros.copy() + casilleros.copy()).subList(inicio, inicio + unNumero).drop(1)
    }

	method indiceDeCasillero(unCasillero) {
 		return self.indice(unCasillero, 0)
 	}
 
 	method indice(unCasillero, index) {
	 	if (unCasillero == casilleros.get(index)) {
	 		return index
	 	} else {
	 		return self.indice(unCasillero, index + 1)
	 	}
 	}
}

class Juego {
    var jugadores = new List()
        
    method agregarJugador(unJugador) {
        jugadores.add(unJugador)    
    }
    
    method empezar() {
        if (self.estaTerminado()) {
            jugadores.forEach({ jugador => self.haceQueJuegue(jugador) })
            self.empezar()
        }    
    }
    
    method estaTerminado() {
        return jugadores.any({ jugador => jugador.tieneTodasLasPropiedades() }) 
    }
    method haceQueJuegue(unJugador) {
        // TODO: HACERLO
    }
}

class Provincia {
	var campos = #{}
	method duenios() {
		return campos.map({campo => campo.duenio()})
	}
	method cuantosCamposTiene(){
		return campos.size()
	}
	method esMonopolioDe(unJugador) {
		return campos.all({campo => campo.duenio() == unJugador})
	}
	method esConstruccionParejaPara(unCampo) {
		return campos.all({campo => campo.estancias() <= unCampo.estancias()})
	}
	method puedeConstruir(unJugador, unCampo) {
		return self.esMonopolioDe(unJugador) 
		and self.esConstruccionParejaPara(unCampo)
	}
}

class Propiedad {
	var duenio = banco
	var valorPropiedad
	
	constructor(precioDeCompraInicial) {
		valorPropiedad = precioDeCompraInicial
	}

	method esCompradaPor(unJugador) {
		duenio = unJugador
		duenio.pagar(valorPropiedad)
	}
	method duenio(){
		return duenio
	}
	method paso(unJugador)
	method cayo(unJugador){
		if(duenio == banco)		self.esCompradaPor(unJugador)
		if(duenio != unJugador)	self.pagarRenta(unJugador)
	}
	method pagarRenta(unJugador)
}

class Campo inherits Propiedad{
	var provincia
	var renta
	var precioDeConstruccion
	var cantidadDeEstancias = 0
		
	constructor (unaProvincia,valorRenta, valorEstancia, precioDeCompraInicial) = 
		super(precioDeCompraInicial){
		renta = valorRenta
		provincia = unaProvincia
		precioDeConstruccion = valorEstancia
	}
	method estancias() {
		return cantidadDeEstancias
	}
	method agregarEstancia(){
		if (provincia.puedeConstruir(duenio, self)){
			cantidadDeEstancias += 1
			duenio.pagar(precioDeConstruccion)
			}
	}
	method sosEmpresa() {
		return false
	}
	method rentaPara(jugadorQueCayo) {
		return (2 ** cantidadDeEstancias) * renta
	}
	override method pagarRenta(unJugador) {
		var deuda = self.rentaPara(unJugador)
		unJugador.pagarA(duenio,deuda)
	}
}

class Empresa inherits Propiedad {
	
	constructor(precioDeCompraInicial) = super(precioDeCompraInicial)
	
	method sosEmpresa() {
		return true
	}
	method rentaPara(jugadorQueCayo) {
		return jugadorQueCayo.tirarDados() * 30000 * duenio.cantidadDeEmpresas()
	}
	override method pagarRenta(unJugador) {
		var deuda = self.rentaPara(unJugador)
		unJugador.pagarA(duenio,deuda)
	}
}

class Jugador {
	var dinero
	var propiedades = #{}
	
	constructor(montoInicial) {
		dinero = montoInicial
	}
	method pagar(monto){
		dinero -= monto
	}
	method comprar(unaPropiedad) {
		propiedades.add(unaPropiedad)
		unaPropiedad.esCompradaPor(self)
	}
	method cantidadDeEmpresas() {
		return propiedades.count({propiedad => propiedad.sosEmpresa()})
	}
	method tirarDados() {
		return [7,8,9,10,11,12].anyOne()
	}
	method pagarA(acreedor, monto) {
		self.puedePagar(monto)
		self.pagar(monto)
		acreedor.cobrar(monto)
	}
	method puedePagar(monto){
		if (monto <= dinero)
		error.throwWithMessage("No puede pagar")
	}
	method cobrar(monto) {
		dinero += monto
	}
	method moverseSobre(casilleros) {
		casilleros.forEach({})
	}
}

object banco {
	var dinero
	var propiedades = #{}
	
	method pagar(monto){
		dinero -= monto
	}
	method comprar(unaPropiedad) {
		propiedades.add(unaPropiedad)
		unaPropiedad.esCompradaPor(self)
	}
	method pagarA(acreedor, monto) {
		self.puedePagar(monto)
		self.pagar(monto)
		acreedor.cobrar(monto)
	}
	method puedePagar(monto){
		if (monto <= dinero)
		error.throwWithMessage("No puede pagar")
	}
	method cobrar(monto) {
		dinero += monto
	}
}

object salida {
	
	method paso(unJugador){
		unJugador.cobrar(5000)
	}
	method cayo(unJugador){}
}

object premioGanadero {
	
	method paso(unJugador){}
	method cayo(unJugador){
		unJugador.cobrar(2500)
	}
}