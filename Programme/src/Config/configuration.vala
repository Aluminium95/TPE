using GLib;
using Gtk;

/**
 * Application qui va faire une surcouche 
 * pour gérer le fichier de configuration 
 */
public class Main : Gtk.Window { // Descend d'une fenêtre !

	public GLib.KeyFile parser; // Parser de fichiers de configuration
	
	/**
	 * Constructeur 
	 */
	public Main () {
		this.border_width = 10; // Bordure de la fenêtre
		
		try {
			/**
			 * Création du parser et chargement du fichier
			 */
			this.parser = new GLib.KeyFile ();
			this.parser.load_from_file (Config.DATA + "/values.conf",GLib.KeyFileFlags.NONE);
		} catch (Error e) {
			stderr.printf ("Impossible de charger la configuration : %s\n", e.message);
		}
		
		
		this.create_entry ();
		
		/**
		 * Configuration de la fenêtre
		 */
		this.title = "Configuration";
		this.resizable = false;
		this.width_request = 500;
    		this.destroy.connect (Gtk.main_quit);
    		
    		/**
    		 * Affichage de la fenêtre 
    		 */
		this.show_all ();
	}
	
	private void create_entry () {
		/**
		 * Crée une boite verticale 
		 */
		var bigVBox = new Gtk.VBox (false, 5);
		
		try { 
			/**
			 * Récupère les groupes de configuration 
			 */
			var groups = this.parser.get_groups ();
			
			// Pour chaque groupe 
			foreach (var group in groups) {
				// on crée un expander ( un truc qui contient des choses que l'on peut cacher )
				var expander = new Expander (group);
				
				/**
				 * Crée une boite verticale 
				 */
				var vbox = new Gtk.VBox (true, 3);
				
				try {
					/** 
					 * Récupère les membres du groupe
					 */
					var members = this.parser.get_keys (group);
					
					// pour chaque membre 
					foreach (var member in members) {
						// crée une boite horizontale 
						var hbox = new Gtk.HBox (true, 3);
						
						// Ajoute un label avec le nom du membre 
						hbox.pack_start (new Label (member + " : "),false, false, 0);
						var entry = new Gtk.Entry ();
						entry.text = this.parser.get_value (group, member);
				
						var g = group;
						var m = member;
						entry.changed.connect (() => { parser.set_value (g,m,entry.text); });
				
						hbox.pack_end (entry, true, true, 0);
				
						vbox.add (hbox);
					}
					expander.add (vbox);
					bigVBox.add (expander);
				} catch (Error e) {
					stderr.printf ("Impossible de créer les membres : %s", e.message);
				}
			}
			var bouton = new Gtk.Button.with_label ("Enregistrer");
			bouton.clicked.connect ( () => {
				try {
					var file = File.new_for_path (Config.DATA + "/values.conf");
			
					if (file.query_exists ()) {
					    file.delete ();
					}
			
					var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
			
					string text = parser.to_data ();
					// For long string writes, a loop should be used, because sometimes not all data can be written in one run
					// 'written' is used to check how much of the string has already been written
					uint8[] data = text.data;
					long written = 0;
					while (written < data.length) { 
					    // sum of the bytes of 'text' that already have been written to the stream
					    written += dos.write (data[written:data.length]);
					}
				} catch (Error e) {
					stderr.printf ("Impossible de sauvegarder : %s\n", e.message);
				}
			});
		
			bigVBox.pack_end (bouton, true, false, 0);
			add (bigVBox);
		} catch (Error e) {
			stderr.printf ("Impossible de créer les groupes : %s",e.message);
		}
	}

	public static void main (string[] args) {
		Gtk.init (ref args);
		new Main ();
		Gtk.main ();
	}
}
