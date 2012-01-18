using Gtk;

namespace Gablabel
{
	public class PreferencesDialogManager
	{
		private Dialog dialog;
		private MainWindow parent;
		
		public PreferencesDialogManager(MainWindow parent){
			this.parent = parent;
		}
		
		public void run(){
			var builder = new Builder();
			
			try{
				builder.add_from_file(Config.DATADIR + "/preferencesdialog.ui");
			} catch(Error e){
				var messageDialog = new MessageDialog(parent,
				                              DialogFlags.DESTROY_WITH_PARENT,
				                              MessageType.ERROR,
				                              ButtonsType.CLOSE,
				                              _("Cannot launch de preferences dialog: %s"), e.message);
				messageDialog.run();
				messageDialog.destroy();
				return;
			}
			
			dialog = builder.get_object("preferences_dialog") as Dialog;
			var settings = App().settings;
			
			var clipboardEntry = builder.get_object("entry_clipboard") as Entry;
			var selectedEntry = builder.get_object("entry_selected") as Entry;
			
			settings.bind("clipboard-binding", clipboardEntry, "text", SettingsBindFlags.DEFAULT);
			settings.bind("selected-binding", selectedEntry, "text", SettingsBindFlags.DEFAULT);
			
			/*clipboardEntry.text = settings.get_string("clipboard-binding");
			selectedEntry.text = settings.get_string("selected-binding");
			
			clipboardEntry.focus_out_event.connect(() => {
				stdout.printf("Se va a settear\n");
				settings.set_string("clipboard-binding", clipboardEntry.text);
				stdout.printf("Setteado\n");
				return false;
			});
			selectedEntry.focus_out_event.connect((event) => {
				settings.set_string("selected-binding", selectedEntry.text);
				return false;
			});*/
			
			dialog.run();
			dialog.destroy();
		}
	}
}
