package org.uqbar.project.wollok.tests.interpreter

import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith
import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.interpreter.SysoutWollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Abstract base class for all interpreter tests cases.
 * Already has all the necessary behavior and objects 
 * for subclasses just to write the test methods.
 * 
 * @author jfernandes
 */
@RunWith(typeof(XtextRunner))
@InjectWith(typeof(WollokDslInjectorProvider))
abstract class AbstractWollokInterpreterTestCase extends Assert {
	@Inject protected extension ParseHelper<WFile>
	@Inject protected extension ValidationTestHelper
	@Inject protected XtextResourceSet resourceSet;
	protected extension WollokInterpreter interpreter
	public static val EXAMPLES_PROJECT_PATH = "../wollok-examples"

	@Before
	def void setUp() {
		interpreter = new WollokInterpreter(new SysoutWollokInterpreterConsole)
	}

	@After
	def void tearDown() {
		interpreter = null
	}

	def interpret(CharSequence... programAsString) {
		this.interpret(false, programAsString)
	}
	
	def interpretPropagatingErrors(CharSequence programAsString) {
		interpretPropagatingErrors(#[programAsString])
	}
	
	def interpretPropagatingErrors(CharSequence... programAsString) {
		this.interpret(true, programAsString)
	}

	def interpretPropagatingErrors(File fileToRead) {
		try {
			new FileInputStream(fileToRead).parse(URI.createFileURI(fileToRead.path), null, resourceSet) => [
				assertNoErrors
				interpret(true)
			]
		} catch (Throwable t) {
			throw new RuntimeException("Error running test " + fileToRead, t)
		}
	}

	def interpret(Boolean propagatingErrors, CharSequence... programAsString) {
		(programAsString.map[parse(resourceSet)].clone => [
			forEach[assertNoErrors]
			forEach[it.interpret(propagatingErrors)]
		]).last
	}
}
