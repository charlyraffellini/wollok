package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.eclipse.draw2d.ConnectionLayer
import org.eclipse.draw2d.FreeformLayer
import org.eclipse.draw2d.FreeformLayout
import org.eclipse.draw2d.MarginBorder
import org.eclipse.draw2d.ShortestPathConnectionRouter
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.LayerConstants
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editpolicies.RootComponentEditPolicy
import org.eclipse.gef.editpolicies.XYLayoutEditPolicy
import org.eclipse.gef.requests.ChangeBoundsRequest
import org.eclipse.gef.requests.CreateRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.MoveOrResizeCommand

/**
 * @author jfernandes
 */
class ClassDiagramEditPart extends AbstractGraphicalEditPart implements PropertyChangeListener {

	override activate() {
		if (!active) {
			super.activate;
			modelElement.addPropertyChangeListener(this)
		}
	}

	override createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new RootComponentEditPolicy)
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new ClassDiagramEditPart.ShapesXYLayoutEditPolicy)
	}

	override createFigure() {
		new FreeformLayer => [f|
			f.border = new MarginBorder(3)
			f.layoutManager = new FreeformLayout

			val connLayer = getLayer(LayerConstants.CONNECTION_LAYER) as ConnectionLayer
			connLayer.setConnectionRouter(new ShortestPathConnectionRouter(f))
		]
	}

	override deactivate() {
		if (active) {
			super.deactivate;
			modelElement.removePropertyChangeListener(this);
		}
	}
	
	def getModelElement() { model as ClassDiagram }
	override getModelChildren() { modelElement.getChildren }

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (ClassDiagram.CHILD_ADDED_PROP == prop || ClassDiagram.CHILD_REMOVED_PROP == prop)
			refreshChildren
	}

	private static class ShapesXYLayoutEditPolicy extends XYLayoutEditPolicy {
		override createChangeConstraintCommand(ChangeBoundsRequest request, EditPart child, Object constraint) {
			if (child instanceof ClassEditPart && constraint instanceof Rectangle)
				// return a command that can move and/or resize a Shape
				new MoveOrResizeCommand(child.model as Shape, request, constraint as Rectangle)
			else
				super.createChangeConstraintCommand(request, child, constraint)
		}
		
		override protected createChildEditPolicy(EditPart child) {
			super.createChildEditPolicy(child)
		}

		override createChangeConstraintCommand(EditPart child, Object constraint) {
			null
		}

		override getCreateCommand(CreateRequest request) {
			null
		}

	}

}