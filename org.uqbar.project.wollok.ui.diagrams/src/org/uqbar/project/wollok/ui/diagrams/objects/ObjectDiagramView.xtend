package org.uqbar.project.wollok.ui.diagrams.objects

import java.util.ArrayList
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.IFigure
import org.eclipse.gef.DefaultEditDomain
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.commands.CommandStack
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.ISelectionProvider
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IPartListener
import org.eclipse.ui.ISelectionListener
import org.eclipse.ui.IViewSite
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.PartInitException
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.uqbar.project.wollok.ui.diagrams.classes.CustomPalettePage
import org.uqbar.project.wollok.ui.diagrams.classes.WollokDiagramsPlugin
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassDiagram
import org.uqbar.project.wollok.ui.diagrams.objects.parts.ObjectDiagramEditPartFactory

/**
 * 
 * @author jfernandes
 */
class ObjectDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IStackFrameConsumer {
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	ActionRegistry actionRegistry
	
	ClassDiagram diagram
	
	DebugContextListener debugListener
	
	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider
	
	new() {
		editDomain = new DefaultEditDomain(null)
//		editDomain.paletteRoot = ClassDiagramPaletterFactory.create
	}
	
	override init(IViewSite site) throws PartInitException {
		super.init(site)
		// listen for selection
		site.workbenchWindow.selectionService.addSelectionListener(this)
		site.workbenchWindow.activePage.addPartListener(this)
		site.selectionProvider = this
	}
	
	def createDiagramModel() {
		null
	}
	
	override createPartControl(Composite parent) {
		splitter = new FlyoutPaletteComposite(parent, SWT.NONE, site.page, paletteViewerProvider, palettePreferences);
		createViewer(splitter)
		
		splitter.graphicalControl = graphicalViewer.control
		if (page != null) {
			splitter.externalViewer = page.getPaletteViewer
			page = null
		}
		
		debugListener = new DebugContextListener(this);
		DebugUITools.getDebugContextManager().addDebugContextListener(debugListener);

		// Check if there is an already started debug context
		val dc = DebugUITools.getDebugContext();
		if (dc != null) {
			val o = dc.getAdapter(IStackFrame)
			if (o instanceof IStackFrame)
				setStackFrame(o as IStackFrame)
		}
		
		// set initial content based on active editor (if any)
		partBroughtToTop(site.page.activeEditor)
	}
	
	def createViewer(Composite parent) {
		val viewer = new ScrollingGraphicalViewer
		viewer.createControl(parent)
		
		setGraphicalViewer(viewer)
		
		configureGraphicalViewer
		hookGraphicalViewer
		initializeGraphicalViewer
		
		// provides selection
		site.selectionProvider = graphicalViewer
	}
	
	def configureGraphicalViewer() {
		graphicalViewer.control.background = ColorConstants.listBackground

		graphicalViewer.editPartFactory = new ObjectDiagramEditPartFactory
		graphicalViewer.rootEditPart = new ScalableFreeformRootEditPart
		graphicalViewer.keyHandler = new GraphicalViewerKeyHandler(graphicalViewer)
	}
	
	def hookGraphicalViewer() {
		selectionSynchronizer.addViewer(graphicalViewer)
		site.selectionProvider = graphicalViewer
	}
	
	def initializeGraphicalViewer() {
		if (model != null) {
			graphicalViewer.contents = model
		}
	}
	
	def setGraphicalViewer(GraphicalViewer viewer) {
		editDomain.addViewer(viewer)
		graphicalViewer = viewer
//		graphicalViewer.addSelectionChangedListener(this)
	}
	
	override setFocus() {
		graphicalViewer.control.setFocus
	}
	
	def getActionRegistry() {
		if (actionRegistry == null) actionRegistry = new ActionRegistry
		actionRegistry
	}
	def CommandStack getCommandStack() {
		editDomain.commandStack
	}
	
	override getAdapter(Class type) {
		if (type == IPropertySheetPage) {
			new UndoablePropertySheetPage(commandStack,
					getActionRegistry.getAction(ActionFactory.UNDO.id),
					getActionRegistry.getAction(ActionFactory.REDO.id))
		}
		else if (type == GraphicalViewer) graphicalViewer
		else if (type == CommandStack) commandStack
		else if (type == ActionRegistry) actionRegistry
		else if (type == EditPart && graphicalViewer != null) graphicalViewer.rootEditPart
		else if (type == IFigure && graphicalViewer != null) (graphicalViewer.rootEditPart as GraphicalEditPart).figure
		else super.getAdapter(type)
	}
	
	def createPalettePage() {
//		new CustomPalettePage(paletteViewerProvider, this);
	}
	
	def getSelectionSynchronizer() {
		if (synchronizer == null) synchronizer = new SelectionSynchronizer
		synchronizer
	}
	
	def getModel() {
		diagram
	}
	
	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if (actionRegistry != null) actionRegistry.dispose
		
		super.dispose
	}
	
	override setSourceViewer(ISourceViewer sourceViewer) { }
	
	// ****************************	
	// ** Palette
	// ****************************
	
	def getSplitter() { splitter }
	def getPaletteViewerProvider() {
		if (provider == null) provider = createPaletteViewerProvider
		provider
	}
	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }
	def getPalettePreferences() { FlyoutPaletteComposite.createFlyoutPreferences(WollokDiagramsPlugin.getDefault.pluginPreferences) }

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	
	override partActivated(IWorkbenchPart part) { }
	override partBroughtToTop(IWorkbenchPart part) { }
	override partClosed(IWorkbenchPart part) { }
	override partDeactivated(IWorkbenchPart part) { }
	override partOpened(IWorkbenchPart part) { }
	override selectionChanged(IWorkbenchPart part, ISelection selection) {	}

	// SELECTION PROVIDER
	val listeners = new ArrayList<ISelectionChangedListener>
	var ISelection selection = null
	
	override addSelectionChangedListener(ISelectionChangedListener listener) { listeners += listener }
	override removeSelectionChangedListener(ISelectionChangedListener listener) { listeners -= listener }
	override getSelection() { selection }
	override setSelection(ISelection selection) { }
	override selectionChanged(SelectionChangedEvent event) { }
	
	// posta
	
	override setStackFrame(IStackFrame stackframe) { graphicalViewer.contents = stackframe }
	
}