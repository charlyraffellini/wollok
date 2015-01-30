package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test

/**
 * 
 * @author jfernandes
 */
class ConstructorTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Test
	def void testConstructorParameterTypeInferredFromInstVarAssignment() {	 '''
			class Direccion {
				var calle = ""
				var numero = 0
				
				new(c, n) {
					calle = c
					numero = n
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertConstructorType("Direccion", "(String, Int)")
		]
	}
	
}