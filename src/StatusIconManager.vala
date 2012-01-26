using Gtk;
using AppIndicator;

namespace Gablabel
{
	public class StatusIconManager
	{
		private MainWindow parent;
		private Indicator indicator;
		private MenuItem itemShowHide;
		private bool mustShowWindow;
		private MenuItem itemClipboard;
		private MenuItem itemSelected;
		
		public StatusIconManager(MainWindow parent) throws GLib.Error
		{
			this.parent = parent;
		
			//Menu creation
			var menuBuilder = new Builder();
			menuBuilder.add_from_file(Config.DATADIR + "/statusmenu.ui");
		
			var statusmenu = menuBuilder.get_object("statusmenu") as Menu;
			itemShowHide = menuBuilder.get_object("showhide") as MenuItem;
			itemClipboard = menuBuilder.get_object("clipboard") as MenuItem;
			itemSelected = menuBuilder.get_object("selected") as MenuItem;
		
			indicator = new Indicator("Gablabel", "gablabel", IndicatorCategory.APPLICATION_STATUS);
			indicator.set_menu(statusmenu);
		
			//Signal connection
			itemShowHide.activate.connect(on_show_hide_activated);
			itemClipboard.activate.connect(on_clipboard_activated);
			itemSelected.activate.connect(on_selected_activated);
			(menuBuilder.get_object("preferences") as ImageMenuItem).activate.connect(parent.show_preferences_dialog);
			(menuBuilder.get_object("about") as ImageMenuItem).activate.connect(parent.show_about_dialog);
			(menuBuilder.get_object("quit") as ImageMenuItem).activate.connect(Gtk.main_quit);
			parent.show.connect(() => {
				refresh_show_hide_label();
			});
			parent.hide.connect(() => {
				refresh_show_hide_label();
			});
		}
		
		public void start(){
			indicator.set_status(IndicatorStatus.ACTIVE);
		}
		
		public void refresh_show_hide_label(bool force = false, bool visibilityValue = true){
			bool isVisible;
			
			if(force){
				isVisible = visibilityValue;
			} else{
				isVisible = parent.get_visible();
			}
			
			if(isVisible){
				itemShowHide.label = _("Hide the translator window");
			} else{
				itemShowHide.label = _("Show the translator window");
			}
			this.mustShowWindow = !isVisible;
		}
		
		public void on_show_hide_activated(){
			if(this.mustShowWindow){
				this.parent.show();
			} else{
				this.parent.hide();
			}
		}
		
		public void on_clipboard_activated(){
			parent.set_source_text_from_clipboard();
			parent.present();
		}
		
		public void on_selected_activated(){
			parent.set_source_text_from_selection();
			parent.present();
		}
	}
}
