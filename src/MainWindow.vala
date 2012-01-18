using Gtk;

namespace Gablabel
{
	public class MainWindow : Window
	{
		private TranslatorWebView webView;
		private Label auxLabel;
		private Menu mainMenu;
		private ToolButton buttonReload;
		private ImageMenuItem menuItemReload;
		private bool isFullscreen;
		
		public MainWindow() throws Error{
			//Widgets creation
			var builder = new Builder();
			builder.add_from_file(Config.DATADIR + "/mainwindow.ui");
			
			var central_widget = builder.get_object("central_widget") as VBox;
			(builder.get_object("mainwindow") as Window).remove(central_widget);
			this.add(central_widget);
			
			webView = new TranslatorWebView();
			(builder.get_object("web_view_parent") as ScrolledWindow).add(webView);
			
			auxLabel = builder.get_object("aux_label") as Label;
			mainMenu = builder.get_object("main_menu") as Menu;
			buttonReload = builder.get_object("toolbutton_reload") as ToolButton;
			menuItemReload = builder.get_object("main_menu_reload") as ImageMenuItem;
			
			//Signals connection
			this.delete_event.connect(this.hide_on_delete);
			this.window_state_event.connect(on_window_state_event);
			
			webView.translator_load_started.connect(on_translator_load_started);
			webView.translator_load_finished.connect(on_translator_load_finished);
			
			var buttonMainMenu = (builder.get_object("toolbutton_menu") as MenuToolButton);
			buttonMainMenu.set_menu(mainMenu);
			buttonMainMenu.clicked.connect(() => { buttonMainMenu.show_menu(); });
			buttonReload.clicked.connect(webView.load_translator);
			(builder.get_object("toolbutton_preferences") as ToolButton).clicked.connect(show_preferences_dialog);
			
			(builder.get_object("main_menu_fullscreen") as ImageMenuItem).activate.connect(() => {
				if(this.isFullscreen){
					this.unfullscreen();
				} else{
					this.fullscreen();
				}
			});
			menuItemReload.activate.connect(webView.load_translator);
			(builder.get_object("main_menu_preferences") as ImageMenuItem).activate.connect(show_preferences_dialog);
			(builder.get_object("main_menu_about") as ImageMenuItem).activate.connect(show_about_dialog);
			(builder.get_object("main_menu_quit") as ImageMenuItem).activate.connect(Gtk.main_quit);
		}
		
		public void start() {
			this.default_height = 420;
			this.default_width = 840;
			this.show_all();
			
			webView.load_translator();
		}
		
		public void on_translator_load_started() {
			webView.get_parent().hide_all();
			auxLabel.label = _("Loading Google Translator, please wait...");
			auxLabel.show_all();
			buttonReload.sensitive = false;
			menuItemReload.sensitive = false;
		}
		
		public void on_translator_load_finished(){
			webView.get_parent().show_all();
			auxLabel.hide_all();
			buttonReload.sensitive = true;
			menuItemReload.sensitive = true;
		}
		
		public bool on_window_state_event(Gdk.EventWindowState event){
			this.isFullscreen = event.new_window_state == Gdk.WindowState.FULLSCREEN;
			
			return false;
		}
		
		public void show_about_dialog(){
			var dialog = new AboutDialog();
			
			const string authors[] = {
				"Damián Nohales <damiannohales@gmail.com>"
			};
			
			dialog.copyright = _("Copyright © 2011 by Damián Nohales");
			dialog.program_name = _("Gablabel Translator");
			dialog.version = Config.PACKAGE_VERSION;
			dialog.authors = authors;
			
			dialog.run();
			dialog.destroy();
		}
		
		public void show_preferences_dialog(){
			var preferences = new PreferencesDialogManager(this);
			preferences.run();
		}
		
		public void set_source_text(string text){
			this.webView.set_source_text(text);
		}
		
		public void set_source_text_from_clipboard(){
			var clipboard = Clipboard.get(Gdk.SELECTION_CLIPBOARD);
			var text = clipboard.wait_for_text();
			if(text != null){
				this.set_source_text(text);
			}
		}
		
		public void set_source_text_from_selection(){
			var clipboard = Clipboard.get(Gdk.SELECTION_PRIMARY);
			var text = clipboard.wait_for_text();
			if(text != null){
				this.set_source_text(text);
			}
		}
	}
}
