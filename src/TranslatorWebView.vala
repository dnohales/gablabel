using Gtk;
using WebKit;

namespace Gablabel
{
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
			this.load_uri(TRANSLATOR_URL);
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
				
				this.load_uri(TRANSLATOR_URL+"#en|es|%20");
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
				this.execute_script(script);
			} catch(Error e){
			}
		}
	}
}
