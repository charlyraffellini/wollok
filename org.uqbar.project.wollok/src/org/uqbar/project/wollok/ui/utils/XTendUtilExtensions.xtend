package org.uqbar.project.wollok.ui.utils

import java.io.PrintWriter
import java.io.StringWriter
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.util.Collection
import java.util.Random
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.nativeobj.WollokDouble
import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger

/**
 * Utilities for xtend code
 * 
 * @author jfernandes
 */
class XTendUtilExtensions {
	
	def static stackTraceAsString(Throwable e) {
		val s = new StringWriter()
		e.printStackTrace(new PrintWriter(s));
		s.buffer.toString
	}
	
	def static bothNull(Object a, Object b) { a == null && b == null }
	def static noneAreNull(Object a, Object b) { a != null && b != null }
	
	// ***************************************
	// ** Collections
	// ***************************************
	
	/** A "map" whose closure receives the index (position) besides the item */
	def static <E,T> Collection<T> map(Iterable<E> col, (Integer,E)=>T mapper) {
		val r = newArrayList
		col.fold(0)[i, e | r.add(mapper.apply(i, e)); i + 1]
		r
	}
	
	def static <E> E findFirstIfNone(Iterable<E> col, (E)=>Boolean predicate, ()=>E ifNone) {
		val f = col.findFirst(predicate)
		if (f != null) 	f else ifNone.apply
	}
	
	def static <E,T> findFirstAndMap(Iterable<E> col, (E)=>Boolean predicate, (E)=>T ifFoundDo) {
		findFirstAndMap(col, predicate, ifFoundDo, [| ])
	}
	
	def static <E,T> void findFirstAndDo(Iterable<E> col, (E)=>Boolean predicate, (E)=>void ifFoundDo) {
		val f = col.findFirst(predicate)
		if (f != null)
			ifFoundDo.apply(f)
	}
	
	def static <E,T> findFirstAndMap(Iterable<E> col, (E)=>Boolean predicate, (E)=>T ifFoundDo, ()=>T ifNotThen) {
		val f = col.findFirst(predicate)
		if (f != null)
			ifFoundDo.apply(f)
		else
			ifNotThen.apply
	}
	
	def static <E> removeAllSuchAs(Collection<E> col, (E)=>Boolean predicate) {
		col.removeAll(col.filter(predicate))
	}
	
	def static <E> maxBy(Collection<E> col, (E)=>Comparable func) {
		col.collectComparing(func, [a,b| a > b])
	}
	
	def static <E> minBy(Collection<E> col, (E)=>Comparable func) {
		col.collectComparing(func, [a,b| a < b])
	}
	
	def static <A,B,O> Collection<O> zip(Iterable<A> colA, Iterable<B> colB, (A,B)=>O zipFunc) {
		colA.map[i,a| zipFunc.apply(a, colB.get(i)) ]
	}
	
	/** reused method between maxBy and minBy */
	def static <E> collectComparing(Collection<E> col, (E)=>Comparable func, (Comparable,Comparable)=>Boolean comparator) {
		var Comparable accVal = null
		var E accE = null
		for (e : col) {
			val thisVal = func.apply(e)
			if (accE == null || comparator.apply(thisVal, accVal)) {
				accVal = thisVal
				accE = e
			}
		}
		accE
	}
	
	// ***************************************
	// ** Wollok -> Native Java interaction
	// ***************************************
	
	def static invoke(Object target, String message, Object... args) {
		// native objects
		var matchingMethods = target.class.methods.filter[name == message && parameterTypes.size == args.size]
		if (matchingMethods.isEmpty)
			throw new MessageNotUnderstood(createMessage(target,message))
		if (matchingMethods.size > 1)
			throw new RuntimeException('''Cannot call on object «target» message «message» there are multiple options !! Not yet implemented''')
		// takes the first one and tries out :S Should do something like multiple-dispatching based on args. 
		matchingMethods.head.accesibleVersion.invokeConvertingArgs(target, args)
	}
	
	def static dispatch createMessage(Object target, String message){
		'''«target» does not understand «message»'''.toString
	}

	def static dispatch createMessage(String target, String message){
		'''"«target»" does not understand «message»'''.toString
	}
	
	def static invokeConvertingArgs(Method m, Object o, Object... args) {
		if (m.parameterTypes.size != args.size) {
			throw new RuntimeException('''Wrong number of arguments for message: «m.name» expected arguments "«m.parameterTypes.map[simpleName]»". Given arguments «args»''') 
		}
		val converted = newArrayList
		args.fold(0)[i, a | converted.add(a.convertTo(m.parameterTypes.get(i))); i + 1 ]
		m.invoke(o, converted.toArray)
	}
	
	def static Object convertTo(Object o, Class<?> t) {
		// acá hace falta diseño. Capaz con un "NativeConversionsProvider" y registrar conversiones.
		if (o instanceof WollokClosure && t == Function1)
			return [Object a | (o as WollokClosure).apply(a)]
		if (o instanceof WollokInteger && (t == Integer || t == Integer.TYPE))
			return (o as WollokInteger).wrapped
		if (o instanceof WollokDouble && (t == Double || t == Double.TYPE))
			return (o as WollokDouble).wrapped
		if (t == Object)
			return o
		if(t.primitive)
			return o	
		
		throw new RuntimeException('''Cannot convert parameter "«o»" to type "«t.simpleName»""''')
	}
	
	def static accesibleVersion(Method m) {
		var c = m.declaringClass
		var metodin = m
		while(metodin.cannotBeCalled() && c != null) { 
			c = c.superclass
			metodin = c.getMethod(m.name, m.parameterTypes)
		}
		metodin
	}
	
	def static cannotBeCalled(Method m) {
		!m.isPublic || !m.declaringClass.isPublic
	}
	
	def static isPublic(Method m) { Modifier.isPublic(m.modifiers) }
	def static isPublic(Class<?> c) {	Modifier.isPublic(c.modifiers)	}
	
	def static randomBetween(int a, int b) {
		new Random().nextInt(b-a) + a
	}
	
	def static <T> T readPrivateField(Object o, String fieldName) {
		val field = o.class.declaredFields.findFirst[name == fieldName]
		field.accessible = true
		try
			field.get(o) as T
		finally
			field.accessible = false
	}
	
	def static toPhrase(String string) {
		(Character.toUpperCase(string.charAt(0)) + string.substring(1)).splitCamelCase
	}
	
	def static splitCamelCase(String s) {
   		s.replaceAll(String.format("%s|%s|%s",
         	"(?<=[A-Z])(?=[A-Z][a-z])",
         	"(?<=[^A-Z])(?=[A-Z])",
         	"(?<=[A-Za-z])(?=[^A-Za-z])"),
      	" ")
	}
	
	def static int randonBetween(int Min, int Max) {
		Min + (Math.random() * ((Max - Min) + 1)).intValue
	}
	
}