package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.uqbar.project.wollok.ui.WollokActivator

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*
import static org.uqbar.project.wollok.validation.WollokDslValidator.*

/**
 * @author jfernandes
 */
//TODO: must rebuild project on apply/save
class TypeSystemConfigurationBlock extends OptionsConfigurationBlock {
	static val SETTINGS_SECTION_NAME = "TypeSystemConfigurationBlock"
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		store.setDefault(TYPE_SYSTEM_CHECKS_ENABLED, IPreferenceStore.TRUE)
	}
	
	override doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginHeight = 20
				marginWidth = 8
			]
			addCheckBox(it, "Enable Type System Checks", TYPE_SYSTEM_CHECKS_ENABLED, booleanPrefValues, 0)
		]
	}
	
	override protected getBuildJob(IProject project) {
		new OptionsConfigurationBlock.BuildJob("Saving Type system configuration", project) => [
			rule = ResourcesPlugin.getWorkspace.ruleFactory.buildRule
			user = true	
		]
	}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {
		#["TypeSystem settings", if (workspaceSettings)	"Apply changed workspace-wide ? All wollok projects will be rebuilt" else "Apply changes for this project ? It will be rebuilt" ]
	}
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
	}
	
	override dispose() {
		storeSectionExpansionStates = WollokActivator.getInstance.dialogSettings.addNewSection(SETTINGS_SECTION_NAME)
		super.dispose
	}
	
}