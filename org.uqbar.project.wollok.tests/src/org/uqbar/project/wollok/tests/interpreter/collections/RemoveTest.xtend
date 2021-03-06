package org.uqbar.project.wollok.tests.interpreter.collections

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * @author tesonep
 */
class RemoveTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testSuperInvocation() { #['''
		object pajarera{
			val pajaros = #[]
			method agregar(unPajaro){
				pajaros.add(unPajaro)
			}
			method quitar(unPajaro){
				pajaros.remove(unPajaro)
			}
			method cantidad(){
				return pajaros.size()
			}
		}
		
		object pepita{
			
		}
		''',
		'''
		program p {
			pajarera.agregar(pepita)
			pajarera.quitar(pepita)
			this.assert(pajarera.cantidad() == 0)
		}'''].interpretPropagatingErrors
	}
	
	@Test
	def void test_issue_40() {
		#['''
		object pajarera {
		    var energiaMenor = 100 
		    var pajaros = #[pepita, pepe]
		    method menorValor(){
		        pajaros.forEach[a | a.sosMenor(energiaMenor)]
		        return energiaMenor
		    }      
		
		    method setEnergiaMenor(valor){
		        energiaMenor = valor
		    }
		}
		
		object pepe {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(10)
		    }
		}
		
		object pepita {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(25)
		    }
		}
		''',
		'''
		program p {
			val menor = pajarera.menorValor()
			this.assertEquals(10, menor)
		}
		'''
		].interpretPropagatingErrors
	}
}
