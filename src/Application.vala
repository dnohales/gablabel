namespace Gablabel
{
	public class Application : GLib.Object
	{
		private static Application singleton_instance = null;
		
		public static Application get_instance(){
			return Application.singleton_instance;
		}
		
		public MainWindow window { get; private set; }
		public StatusIconManager statusIcon { get; private set; }
		public KeyBindingManager keyBindings { get; private set; }
		public GLib.Settings settings { get; private set; }
		private Gee.Map<string, string> currentBindings = new Gee.HashMap<string, string>();
		
		private Application(string[] args){
			Application.singleton_instance = this;
			
			Gtk.init(ref args);

			Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
			Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
			Intl.textdomain( Config.GETTEXT_PACKAGE );
		}
		
		public int run(){
			try{
				keyBindings = new KeyBindingManager();
				
				settings = new GLib.Settings("es.nohal.Gablabel");
				on_settings_changed("clipboard-binding");
				on_settings_changed("selected-binding");
				settings.changed.connect(on_settings_changed);
				
				window = new Gablabel.MainWindow();
				statusIcon = new StatusIconManager(window);
				
				window.start();
				statusIcon.start();
				
				Gtk.main();
				return 0;
			} catch(Error e){
				stderr.printf("Failed to load the UI file: " + e.message);
				return 1;
			}
		}
		
		private KeyBindingManager.KeybindingHandlerFunc? handler_func_by_setting(string key)
		{
			switch(key)
			{
			case "clipboard-binding":
				return () => {
					statusIcon.on_clipboard_activated();
				};
			case "selected-binding":
				return () => {
					statusIcon.on_selected_activated();
				};
			default:
				return null;
			}
		}
		
		private void on_settings_changed(string key)
		{
			switch(key)
			{
			case "clipboard-binding":
			case "selected-binding":
				if(currentBindings.has_key(key)){
					keyBindings.unbind(currentBindings[key]);
				}
				currentBindings[key] = settings.get_string(key);
				keyBindings.bind(currentBindings[key], handler_func_by_setting(key));
				break;
			}
		}
		
		public static int main(string[] args){
			Application a = new Application(args);
			return a.run();
		}
	}

	public Application App(){
		return Application.get_instance();
	}
}
