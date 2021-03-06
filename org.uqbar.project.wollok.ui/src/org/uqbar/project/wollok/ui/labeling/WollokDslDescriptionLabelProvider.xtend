package org.uqbar.project.wollok.ui.labeling

import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.ui.label.DefaultDescriptionLabelProvider

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

/**
 * Provides labels for a IEObjectDescriptions and IResourceDescriptions.
 * see http://www.eclipse.org/Xtext/documentation.html#labelProvider
 * 
 * @author jfernandes
 */
class WollokDslDescriptionLabelProvider extends DefaultDescriptionLabelProvider {
	
//	override text(IEObjectDescription ele) {
//		ele.name.toString
//	}
//	 
	override image(IEObjectDescription ele) {
		switch (ele.EClass) {
			case WCLASS: 'wollok-icon-class_16.png'
			case WPACKAGE: 'package.png'
			
			default: null
		}
	}

}
