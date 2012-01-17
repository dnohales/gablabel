namespace Gablabel
{
	public class Application : GLib.Object
	{
		private static Application singleton_instance = null;
		
		public static Application get_instance(){
			return Application.singleton_instance;
		}
		
		enum BindingName {
			CLIPBOARD,
			SELECTED
		}
		
		public MainWindow window { get; private set; }
		public StatusIconManager statusIcon { get; private set; }
		public KeyBindingManager keyBindings { get; private set; }
		public GLib.Settings settings { get; private set; }
		private Gee.Map<Application.BindingName, string> currentBindings = new Gee.HashMap<Application.BindingName, string>();
		
		private Application(string[] args){
			Gtk.init(ref args);

			Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
			Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
			Intl.textdomain( Config.GETTEXT_PACKAGE );
		}
		
		public int run(){
			try{
				window = new Gablabel.MainWindow();
				statusIcon = new StatusIconManager(window);
				window.start();
				statusIcon.start();
				
				keyBindings = new KeyBindingManager();
				keyBindings.bind("<Ctrl><Alt>S", (event) => {
					statusIcon.on_selected_activated();
				});
				
				settings = new GLib.Settings("es.nohal.gablabel");
				settings.changed
				
				Gtk.main();
				return 0;
			} catch(Error e){
				stderr.printf("Failed to load the UI file: " + e.message);
				return 1;
			}
		}
		
		private void refreshBindings(){
			
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
