package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author tesonep
 */
class TestTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		#[
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}
		''',
		
		'''
			test pepita {
				tester.assert(pepita.energia() == 0)	
				tester.assertEquals(0, pepita.energia())	
				
				pepita.come(10)
				tester.assertEquals(100, pepita.energia())	
			}
		'''].interpretPropagatingErrors
	}

	@Test
	def void testWithAssertEqualsWithErrors() {
		try{
			#[
			'''
				object pepita {
					var energia = 0
					method come(cantidad){
						energia = energia + cantidad * 10
					}
					method energia(){
						return energia
					}
				}
			''',
			
			'''
				test pepita {
					tester.assertEquals(7, pepita.energia())	
				}
			'''].interpretPropagatingErrors
			fail()
		}catch(AssertionError e){
			assertEquals("Expected [7] but found [0]",e.message)
		}
	}

	@Test(expected = AssertionError)
	def void testWithAssertsWithErrors() {
		#[
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}
		''',
		
		'''
			test pepita {
				tester.assert(7 == pepita.energia())	
			}
		'''].interpretPropagatingErrors
	}
	
}