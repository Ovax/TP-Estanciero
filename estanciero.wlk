object tablero {
	var todasLasPropiedades = new List()
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
 	method empresas() {
 		return todasLasPropiedades.filter({propiedad => propiedad.sosEmpresa()})
 	}
 	method dueniosDeEmpresas() {
 		return self.empresas().map({empresa => empresa.duenio()}).asSet()
 	}
 	method aniadirPropiedades(unasPropiedades) {
 		todasLasPropiedades.addAll(unasPropiedades)
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
    	var casilleroInicial = 	unJugador.casilleroActual()
        var dados			 = 	unJugador.tirarDados()
        var casilleros		 = 	tablero.casillerosDesde(casilleroInicial, dados)
        unJugador.moverseSobre(casilleros)
    }
}

class Provincia {
	var campos = #{}
	
	constructor (losCampos) {
		campos.addAll(losCampos)
		losCampos.forEach({campo => campo.aniadirProvincia(self)})
	}	
	method duenios() {
		return campos.map({campo => campo.duenio()}).asSet()
	}
	method cuantosCamposTiene(){
		return campos.size()
	}
	method sePuedeConstruirEn(unCampo) {
		return self.esMonopolioDe(unCampo.duenio()) 
		and self.esConstruccionParejaPara(unCampo)
	}
	method esMonopolioDe(unJugador) {
		return self.duenios() == #{unJugador}
	}
	method esConstruccionParejaPara(unCampo) {
		return campos.all({campo => campo.estancias() <= unCampo.estancias()})
	}
}

class Propiedad {
	var duenio = banco
	var valorPropiedad
	
	constructor(precioDeCompraInicial) {
		valorPropiedad = precioDeCompraInicial
		banco.aniadirPropiedad(self)
	}
	method duenio(){
		return duenio
	}
	method paso(unJugador){}
	method cayo(unJugador){
		if(duenio == banco)		unJugador.estrategiaDeCompraPara(self)
		if(duenio != unJugador)	self.pagarRenta(unJugador)
	}
	method esCompradaPor(unJugador) {
		unJugador.pagarA(duenio,valorPropiedad)
		self.compra(unJugador)
	}
	method compra(unJugador) {
		unJugador.comprar(self)
		duenio = unJugador
	}
	method pagarRenta(unJugador)
	method hipotecar() {
		valorPropiedad = valorPropiedad * 1.5
		banco.pagarA(duenio,self.valorHipoteca())
		self.compra(banco)
	} 
	method valorHipoteca()  =		valorPropiedad / 2 + self.plus()
	method plus() 			=		return 0
}

class Campo inherits Propiedad{
	var provincia
	var renta
	var precioDeConstruccion
	var cantidadDeEstancias = 0
		
	constructor (valorRenta, valorEstancia, precioDeCompraInicial) = 
		super(precioDeCompraInicial){
		renta = valorRenta
		precioDeConstruccion = valorEstancia
	}
	method aniadirProvincia(unaProvincia) {
		provincia = unaProvincia
	}
	method estancias() {
		return cantidadDeEstancias
	}
	method agregarEstancia(){
		if (self.sePuedeConstruir()){
			cantidadDeEstancias += 1
			duenio.pagar(precioDeConstruccion)
			}
	}
	method sePuedeConstruir() {
		return provincia.sePuedeConstruirEn(self)
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
	override method plus() {
		return cantidadDeEstancias * precioDeConstruccion / 2
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
	var dinero = 5000000
	var propiedades = #{}
	var casilleroActual = salida
	var estaPreso = false
	var sacoDoble = false
	var turnosPreso
	var estrategiaDeCompra = standar
	
	constructor(montoInicial) {
		dinero = montoInicial
	}
	method comprar(unaPropiedad) {
		propiedades.add(unaPropiedad)
	}
	method cantidadDeEmpresas() {
		return propiedades.count({propiedad => propiedad.sosEmpresa()})
	}
	method tirarDados() {
		var dado1 = [1,2,3,4,5,6].anyOne()
		var dado2 = [1,2,3,4,5,6].anyOne()
		
		if (estaPreso && self.esDoble(dado1,dado2)) {
			self.salePorSacarDoble()
			return [2,3,4,5,6,7,8,9,10,11,12].anyOne()
		}
		if (estaPreso && turnosPreso <= 3) {
			self.siguePreso()
			return 0
		}
		if (sacoDoble && self.esDoble(dado1, dado2)) {
			self.vaPreso()
			return 0
			}
		else {
			estaPreso = false
			sacoDoble = self.esDoble(dado1,dado2)
			return dado1 + dado2
			}
	}
	method salePorSacarDoble() {
		estaPreso = false
	}
	method esDoble(numero1,numero2) {
		return numero1 == numero2
	}
	method siguePreso() {
		turnosPreso += 1
	}
	method vaPreso() {
			turnosPreso = 0
			estaPreso = true
			sacoDoble = false
			casilleroActual = prision
	}
	method pagarA(acreedor, monto) {
		if (self.leAlcanzaPara(monto)) {
			self.pagoA(acreedor,monto)
		}
		else {
			self.hipotecar()
			self.pagoA(acreedor,monto)
		}
	}
	method pagoA(acreedor,monto) {
		self.pagar(monto)
		acreedor.cobrar(monto)
	}
	method leAlcanzaPara(monto) {
		return dinero >= monto
	}
	method hipotecar() {
		propiedades.forEach({propiedad => propiedad.hipotecar()})
		propiedades.clear()
	}
	method puedePagar(monto){
		if (!self.leAlcanzaPara(monto))		
		error.throwWithMessage("No puede pagar")
	}
	method pagar(monto){
		self.puedePagar(monto)
		dinero -= monto
	}
	method cobrar(monto) {
		dinero += monto
	}
	method moverseSobre(casilleros) {
		casilleros.forEach({propiedad => propiedad.paso(self)})
		casilleroActual = casilleros.last()
		casilleroActual.cayo(self)
	}
	method casilleroActual() {
		return casilleroActual
	}
	method dinero() {
		return dinero
	}
	method compro(propiedad) {
		return propiedades.contains(propiedad)
	}
	method sacoDoble(bool) {
		sacoDoble = bool
	}
	method estrategiaDeCompraPara(unaPropiedad) {
		estrategiaDeCompra.cayoEn(unaPropiedad,self)
	}
	method estrategiaDeCompra(unaEstrategia) {
		estrategiaDeCompra = unaEstrategia
	}
}

object banco {
	var propiedades = #{}
	
	method comprar(unaPropiedad) {
		propiedades.add(unaPropiedad)
	}
	method pagarA(acreedor, monto) {
		acreedor.cobrar(monto)
	}
	method cobrar(monto) {}
	method aniadirPropiedad(unaPropiedad) {
		propiedades.add(unaPropiedad)
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

object prision {
	
	method paso(unJugador){}
	method cayo(unJugador){}
}

object standar {
	method cayoEn(unaPropiedad, unJugador) {
		unaPropiedad.esCompradaPor(unJugador)
	}
}

object garca {
	method cayoEn(unaPropiedad,unJugador) {
		if (unaPropiedad.sosEmpresa())	self.cayoEnEmpresa(unaPropiedad,unJugador)
		else 							self.cayoEnCampo(unaPropiedad,unJugador)
		}
	method cayoEnEmpresa(unaEmpresa,unJugador) {
		if (self.dueniosDeLasDemasEmpresasEsDistintoA(unJugador)){
			unaEmpresa.esCompradaPor(unJugador)
		}
	}
	method dueniosDistintosQue(unJugador,unosDuenios) {
		return unosDuenios.any({duenio => duenio != unJugador && duenio != banco})
	}
	method dueniosDeLasDemasEmpresasEsDistintoA(unJugador) {
		return self.dueniosDistintosQue(unJugador,tablero.dueniosDeEmpresas())
			}
	method yaHayCamposOcupadosPorOtrosJugadoresQue(unJugador,unaProvincia) {
		return self.dueniosDistintosQue(unJugador,unaProvincia.duenios())
	}
	method cayoEnCampo(unCampo,unJugador) {
		if (self.yaHayCamposOcupadosPorOtrosJugadoresQue(unJugador,unCampo.provincia())) {
				unCampo.esCompradaPor(unJugador)
		}
	}
}

object imperialista {
	method cayoEn(unaPropiedad,unJugador) {
		if (unaPropiedad.sosEmpresa())	self.cayoEnEmpresa(unaPropiedad,unJugador)
		else 							self.cayoEnCampo(unaPropiedad,unJugador)
		}
	method cayoEnCampo(unCampo,unJugador) {
		if (self.elJugadorYaTieneAlgunCampoEn(unJugador,unCampo.provincia())
			||	self.todosLosCamposNoTieneDuenioEn(unCampo.provincia())) {
				unCampo.esCompradaPor(unJugador)
			}
	}
	method cayoEnEmpresa(unaEmpresa,unJugador) {
		if (self.todasLasEmpresasNoTienenDuenio()) {
			unaEmpresa.esCompradaPor(unJugador)
		}
	}
	method todasLasEmpresasNoTienenDuenio() {
		return tablero.dueniosDeEmpresas() == #{banco}
	}
	method elJugadorYaTieneAlgunCampoEn(unJugador,unaProvincia) {
		return unaProvincia.any({duenio => duenio == unJugador})
	}
	method todosLosCamposNoTieneDuenioEn(unaProvincia) {
		return unaProvincia.duenios() == #{banco}
	}
}
