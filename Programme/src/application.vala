/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main.c
 * Copyright (C) Babakask 2011 <lopezaliaume@gmail.com>
 * ValaWorms is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * ValaWorms is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using SDL;
using SDLImage;
using SDLMixer;
using Gee;


/**
 * Classe de l'application
 */
public class Main : Object {

	
	public static int32 COULEUR_LIGNE;
	
	public static int COULEUR_FOND;
	
	public static int MIN_PAR_SEC;
	
	public static int time = 0;

	/**
	 * Principaux objets
	 */
	private Affichage aff;
	private Gerant temoin; // Écran témoin
	private Gerant test; // Écran test
	private Menu.Menu menu;

	private Menu.Bouton? action; // Bouton activé / en cours d'utilisation
	
	private bool done;
	private bool pause;

	/**
	 * Constructeur 
	 */
	public Main () {
		COULEUR_LIGNE = 65023;
		COULEUR_FOND = 0;
	
		this.init (); // Init SDL
		
		this.charge_constantes ();
		
		
		this.done = false;
		this.pause = false;
		
		this.aff = new Affichage ();

		/* Construction des Gérants et du menu */ {
			int middle = (int) Affichage.SCREEN_WIDTH / 2;
		
			this.temoin = new Gerant (0, 50, middle, Affichage.SCREEN_HEIGHT - 50, this.aff);
			this.test = new Gerant (middle, 50, middle, Affichage.SCREEN_HEIGHT -50, this.aff);
			this.menu = new Menu.Menu (this.aff);
		}

		this.run ();

		/**
		 * Quitte toutes les libs
		 */
		this.quit ();
	}

	/**
	 * Boucle principale 
	 */
	private void run () {
		var boucle_affichage = new SDL.Timer (20, this.draw);
		var boucle_processus = new SDL.Timer (20, this.process_sim);
		
		while (!done) {
			
			/**
			 * Run le menu
			 
			lock (this.menu) {
				this.menu.run ();
			}
			*/

			/**
			 * Lance la boucle événementielle
			 *	  On peut éviter de la lancer tous les cycles … … 
			 */
			process_event ();
			
			/*
			 * Quitte sans attendre le delai
			 */
			if (done) { break; }

			
			SDL.Timer.delay (50);
		}
		
		boucle_processus.remove ();
		boucle_affichage.remove ();
	}
	
	private uint32 process_sim (uint32 intervalle) {
		if (!pause) {
			lock (this.temoin) {
				this.temoin.run ();
			} 
		
			lock (this.test) {
				this.test.run ();
			}
		}
		
		return intervalle;
	}

	/**
	 * Fonction qui affiche tous les objets et 
	 * rafraichit l'écran
	 */
	private uint32 draw (uint32 intervalle) {
		lock (this.temoin) {
			this.aff.clearrect (this.temoin);
			this.temoin.draw ();
		}
		lock (this.test) {
			this.aff.clearrect (this.test);
			this.test.draw ();
		}
		lock (this.menu) {
			this.aff.clearrect (this.menu);
			this.menu.draw ();
		}
		
		if (!pause) {
			time += 20; // Ajoute 20 ms
		}
		
		int minutes = (time / 1000 * MIN_PAR_SEC);
		int heures = minutes / 60;
		minutes %= 60;
		aff.draw_text(450,25, heures.to_string () + " heures " + minutes.to_string() + " minutes " , 0xFFEEF);
		
		aff.affiche (); // Rafraichit l'écran
		return intervalle;
	}

	/**
	 * Gère les events 
	 */
	private void process_event () {
		
		Event event = Event (); // Récupère tous les événements 

		/**
		 * Pour chaque évent
		 */
		while (Event.poll (out event) == 1) {
			switch (event.type) {
				case EventType.QUIT:
					this.done = true;
					break;
				case EventType.MOUSEBUTTONDOWN:
					var x = event.button.x;
					var y = event.button.y;
					
					if (this.action != null && !this.menu.contains (x,y)) {
						this.execute_action (x,y);
					} else if (this.menu.contains (x,y)) {
						var actionSelect = this.menu.getBtnPos (x,y);
						if (this.action != null && actionSelect != null && actionSelect.action == this.action.action) {
							this.action.active = false;
							this.action = null;
						} else if (this.action == null) {
							this.try_change_action (actionSelect);
						}
					}
					break;
			}
		}
	}

	/** 
	 * Essaye de cliquer sur un 
	 * bouton, et le cas échéan
	 * d'activer l'action si elle est simple
	 */
	private void try_change_action (Menu.Bouton? action) {
		this.action = action;
		if (this.action != null ) {
			switch (this.action.action) {
				case Menu.Action.GRILLE:
					if (Gerant.GRILLE_ACTIVE == true) {
						Gerant.GRILLE_ACTIVE = false;
						this.action.active = false;
					} else {
						Gerant.GRILLE_ACTIVE = true;
						this.action.active = true;
					}
					this.action = null;
					break;
				case Menu.Action.GRILLE_PLUS:
					Gerant.GRILLE_WIDTH++;
					Gerant.GRILLE_HEIGHT++;
					this.action = null;
					break;
				case Menu.Action.GRILLE_MOINS:
					Gerant.GRILLE_WIDTH = (Gerant.GRILLE_WIDTH <= 1) ? 1 : Gerant.GRILLE_WIDTH - 1;
					Gerant.GRILLE_HEIGHT = (Gerant.GRILLE_HEIGHT <= 1) ? 1 : Gerant.GRILLE_HEIGHT - 1;
					this.action = null;
					break;
				case Menu.Action.UV:
					if (this.test.UV == true ) {
						this.test.UV = false;
						this.action.active = false;
					} else {
						this.test.UV = true;
						this.action.active = true;
					}
					this.action = null;
					break;
				case Menu.Action.PAUSE:
					if (this.pause == true) {
						this.pause = false;
						this.action.active = false;
					} else {
						this.pause = true;
						this.action.active = true;
					}
					this.action = null;
					break;
				case Menu.Action.CONFIG:
					int middle = (int) Affichage.SCREEN_WIDTH / 2;
					this.temoin = new Gerant (0, 50, middle, Affichage.SCREEN_HEIGHT - 50, this.aff);
					this.test = new Gerant (middle, 50, middle, Affichage.SCREEN_HEIGHT -50, this.aff);
					// GLib.Process.spawn_command_line_async (Config.DATA + "/../../Build/Config");
					break;
				default: // Pour les autres, on se contente de les activer
					this.action.active = true;
					break;
			}
		}
	}

	/**
	 * Execute l'action 
	 * sélectionnée précédement
	 * ( ne fonctionne qu'avec les actions longues )
	 */
	private void execute_action (int x, int y) {
		assert (this.action != null);
		/**
		 * Action des activés  (actions longues)
		 */
		switch (this.action.action) {
			case Menu.Action.AJOUTER:
				if (this.test.contains (x,y)) {
					this.test.addCell (x,y);
				} else if (this.temoin.contains (x,y)) {
					this.temoin.addCell (x,y);
				}
				break;
			case Menu.Action.SUPPRIMER:
				if (this.test.contains (x,y)) {
					this.test.removeCellPos (x,y);
				} else if (temoin.contains (x,y))  {
					this.temoin.removeCellPos (x,y);
				}
				break;
		}
	}

	/**
	 * Initialise les libs
	 */
	private void init () {
		SDL.init (InitFlag.VIDEO | InitFlag.AUDIO | InitFlag.TIMER);
		SDLImage.init (InitFlag.VIDEO | InitFlag.AUDIO | InitFlag.TIMER);
	}

	/**
	 * Quitte les libs
	 */
	private void quit () {
		SDLImage.quit ();
		SDL.quit ();
	}
	
	/**
	 * Charge les constantes du fichier 
	 * de configuration
	 */
	private void charge_constantes () {
		try {
			var parser = new GLib.KeyFile ();
			parser.load_from_file (Config.DATA + "/values.conf", GLib.KeyFileFlags.NONE);
			
			Affichage.SCREEN_WIDTH = parser.get_integer ("Simulation", "width");
			Affichage.SCREEN_HEIGHT = parser.get_integer ("Simulation", "height");
			
			MIN_PAR_SEC = parser.get_integer ("Simulation", "mins par secondes");
			
			COULEUR_FOND = parser.get_integer ("Affichage", "fond");
			
			Cellule.C_TPS_DIVISION = parser.get_integer ("Cellule", "replication") * 50;
			Cellule.C_TPS_DIE = parser.get_integer ("Cellule", "vie") * 50;
			Cellule.C_HEIGHT = parser.get_integer ("Cellule", "height");
			Cellule.C_WIDTH = parser.get_integer ("Cellule", "width");
			Gerant.DEPL_DIV_ACTIVE = parser.get_boolean ("Cellule", "division pousse");
			
		} catch (GLib.Error e) {
			stderr.printf ("Impossible de changer la configuration : %s\n",e.message);
		}
			
	}


	/**
	 * Main static d'entrée du programme
	 */
	static int main (string[] args) 
	{
		new Main ();
		
		return 0;
	}
}
