using Gtk;
using WebKit;
using Config;
using AppIndicator;

namespace Gablabel
{
    public class StatusIconManager
    {
        private MainWindow parent;
        private Indicator indicator;
        
        public StatusIconManager(MainWindow parent) throws GLib.Error
        {
            var menuBuilder = new Builder();
            menuBuilder.add_from_file(Config.DATADIR + "/statusmenu.ui");
            
            this.parent = parent;
            indicator = new Indicator("Gablabel", "indicator-messages", IndicatorCategory.APPLICATION_STATUS);
            indicator.set_menu(menuBuilder.get_object("statusmenu") as Menu);
            indicator.set_status(IndicatorStatus.ACTIVE);
        }
    }
    
    public class TranslatorWebView : WebView 
    {
        public signal void translator_load_started();
        public signal void translator_load_finished();
        
        private const string TRANSLATOR_URL = "http://translate.google.com/";
        
        public TranslatorWebView() {
            this.document_load_finished.connect(on_download_finish);
        }
        
        public void load_translator()
        {
			this.translator_load_started();
            this.navigation_policy_decision_requested.disconnect(analyze_navigation_policy);
            this.load_uri(TRANSLATOR_URL);
        }
        
        private void reformat_content()
        {
			try{
				string script;
				FileUtils.get_contents(Config.DATADIR + "/content-reformat.js", out script);
				this.execute_script(script);
			} catch(Error e){
			}
        }
        
        private void on_download_finish(WebFrame frame)
        {
            this.navigation_policy_decision_requested.connect(analyze_navigation_policy);
            this.reformat_content();
            this.translator_load_finished();
        }
        
        private bool analyze_navigation_policy(WebFrame frame, NetworkRequest request, WebNavigationAction action, WebPolicyDecision decision) {
            decision.ignore();
            return true;
        }
    }
    
    public class MainWindow : Window
    {
        private StatusIconManager statusIcon;
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
            
            statusIcon = new StatusIconManager(this);
            
            //Signals connection
            this.destroy.connect(Gtk.main_quit);
            this.window_state_event.connect(on_window_state_event);
            
            webView.translator_load_started.connect(on_translator_load_started);
            webView.translator_load_finished.connect(on_translator_load_finished);
            
            var buttonMainMenu = (builder.get_object("toolbutton_menu") as MenuToolButton);
            buttonMainMenu.set_menu(mainMenu);
            buttonMainMenu.clicked.connect(() => { buttonMainMenu.show_menu(); });
            buttonReload.clicked.connect(webView.load_translator);
            
            (builder.get_object("main_menu_fullscreen") as ImageMenuItem).activate.connect(() => {
				if(this.isFullscreen){
					this.unfullscreen();
				} else{
					this.fullscreen();
				}
			});
            menuItemReload.activate.connect(webView.load_translator);
            (builder.get_object("main_menu_about") as ImageMenuItem).activate.connect(show_about_dialog);
            (builder.get_object("main_menu_quit") as ImageMenuItem).activate.connect(Gtk.main_quit);
        }
        
        public void start() {
            this.default_height = 350;
            this.default_width = 800;
            this.show_all();
            
            webView.load_translator();
        }
        
        public void on_translator_load_started() {
            webView.get_parent().hide_all();
            auxLabel.label = "Loading Google Translator, please wait...";
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
			
			dialog.copyright = _("Copyright © 2011 by Damián Nohales");
			dialog.program_name = _("Gablabel Translator");
			dialog.version = Config.PACKAGE_VERSION;
			dialog.authors = {"Damián Nohales <damiannohales@gmail.com>"};
			
			dialog.run();
		}
    }
}

void main(string[] args)
{
    Gtk.init(ref args);
    
    Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
    Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
    Intl.textdomain( Config.GETTEXT_PACKAGE );
    
    try{
        var window = new Gablabel.MainWindow();
        window.start();
            
        Gtk.main();
    } catch(Error e){
        stderr.printf("Failed to load the UI file: " + e.message);
    }
}
