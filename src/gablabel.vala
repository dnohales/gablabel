using Gtk;
using WebKit;
using Config;
using AppIndicator;

namespace Gablabel
{
    /*public class EntryPlaceholderDecorator
    {
        public Entry entry { get; private set; }
        public string placeholder_text { get; set; }
        public string text {
            get {
                if(placeholder_active){
                    return "";
                } else{
                    return entry.text;
                }
            }
            set {
                entry.text = value;
                if(value == ""){
                    placeholder_active = true;
                } else{
                    placeholder_active = false;
                }
                on_focus_out(Gdk.EventFocus());
            }
        }
        
        //private Entry _entry;
        //private string _placeholder_text;
        private bool placeholder_active;
        
        EntryPlaceholderDecorator(Entry e, string p = ""){
            this.entry = e;
            this.placeholder_text = p;
            
            entry.focus_in_event.connect(on_focus_in);
            entry.focus_out_event.connect(on_focus_out);
        }
        
        public bool on_focus_out(Gdk.EventFocus event){
            return false;
        }
        
        public bool on_focus_in(Gdk.EventFocus event){
            if(placeholder_active){
                entry.text = "";
            }
            return false;
        }
    }*/
    
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
            itemSelected.accel_path = "<Control>+<Alt>+S";
            
            indicator = new Indicator("Gablabel", "indicator-messages", IndicatorCategory.APPLICATION_STATUS);
            indicator.set_menu(statusmenu);
            indicator.set_status(IndicatorStatus.ACTIVE);
            
            //Signal connection
            itemShowHide.activate.connect(on_show_hide_activated);
            itemClipboard.activate.connect(parent.set_source_text_from_clipboard);
            itemSelected.activate.connect(parent.set_source_text_from_selection);
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
    }
    
    public class TranslatorWebView : WebView 
    {
        public signal void translator_load_started();
        public signal void translator_load_finished();
        
        private const string TRANSLATOR_URL = "http://translate.google.com/";
        private bool mustNotifyFinish;
        
        public TranslatorWebView() {
            this.document_load_finished.connect(on_download_finish);
        }
        
        public void load_translator()
        {
            this.mustNotifyFinish = true;
			this.translator_load_started();
            this.navigation_policy_decision_requested.disconnect(analyze_navigation_policy);
            this.load_uri(TRANSLATOR_URL+"#en|es|%20");
        }
        
        private void on_download_finish(WebFrame frame){
            if(mustNotifyFinish){
                this.navigation_policy_decision_requested.connect(analyze_navigation_policy);
                
                try{
                    string script;
                    FileUtils.get_contents(Config.DATADIR + "/content-reformat.js", out script);
                    this.execute_script(script);
                } catch(Error e){
                }
                
                this.translator_load_finished();
                this.mustNotifyFinish = false;
            }
        }
        
        private bool analyze_navigation_policy(WebFrame frame, NetworkRequest request, WebNavigationAction action, WebPolicyDecision decision) {
            if(request.get_uri().index_of(TRANSLATOR_URL) == 0){
                return false;
            } else{
                return true;
            }
        }
        
        public void set_source_text(string text){
            try{
				string script;
				FileUtils.get_contents(Config.DATADIR + "/set-source-text.js", out script);
                string finalText;
                finalText = text.replace("\t", "    ").escape("");
                script = script.replace("@SOURCE_TEXT@", finalText);
                stdout.printf(script + "\n");
				this.execute_script(script);
			} catch(Error e){
			}
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
            this.delete_event.connect(this.hide_on_delete);
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
            (builder.get_object("main_menu_preferences") as ImageMenuItem).activate.connect(show_preferences_dialog);
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
            
            const string authors[] = {
                "Damián Nohales <damiannohales@gmail.com>"
            };
			
			dialog.copyright = _("Copyright © 2011 by Damián Nohales");
			dialog.program_name = _("Gablabel Translator");
			dialog.version = Config.PACKAGE_VERSION;
			dialog.authors = authors;
			
			dialog.run();
		}
        
        public void show_preferences_dialog(){
            
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
