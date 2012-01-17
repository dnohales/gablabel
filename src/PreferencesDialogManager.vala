using Gtk;

namespace Gablabel
{
	public class PreferencesDialogManager
	{
		private GLib.Settings settings;
		private Dialog dialog;
		private MainWindow parent;
		
		public PreferencesDialogManager(MainWindow parent){
			this.parent = parent;
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
				return;
			}
			
			dialog = builder.get_object("preferences_dialog") as Dialog;
			settings = App().get_settings();
		}
		
		public void run(){
			dialog.run();
		}
	}
}
