/* -*- Mode: vala; tab-width: 4; intend-tabs-mode: t -*- */
/* valaworms
 *
 * Copyright (C) Babakask 2011 <lopezaliaume@gmail.com>
 * valaworms is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * valaworms is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using GLib;
using Gee;
using SDL;

/**
 * Gestion du menu 
 */
namespace Menu {

	public const int BTN_WIDTH = 50;
	public const int BTN_HEIGHT = 49;
	
	/**
	 * Classe gérant les boutons du menu
	 */
	public class Menu : Rectangle {
		protected Rectangle?[] btns;
		protected weak Affichage aff;
		protected int nbr;
		
		// public signal void UV_changed ();
		public delegate void on_signal_emit ();
		
		// Constructor
		public Menu (Affichage aff) {
			base.menu (Affichage.SCREEN_WIDTH,50);
			
			
			this.nbr = 0;
			
			this.aff = aff;
			
			this.btns = new Rectangle[(int) Affichage.SCREEN_WIDTH / BTN_WIDTH];
			//this.addBouton (Config.UI + "/rm_uv.png", Action.UVM);
			this.addBouton (Config.UI + "/uv.png", Action.UV, Config.UI + "/uv_activated.png");
			//int n = this.addLabel ("1");
			//((Label) this.btns[n]).setImg (Config.UI + "/A.png");
			//this.UV_changed.connect (() => {((Label)this.btns[n]).text = Main.TEST_FACTEUR_MUTATION.to_string ();});
			//this.addBouton (Config.UI + "/add_uv.png", Action.UV);
			this.addBouton (Config.UI + "/plus.png", Action.AJOUTER, Config.UI + "/Splus.png");
			this.addBouton (Config.UI + "/moins.png", Action.SUPPRIMER, Config.UI + "/Smoins.png");
			this.addBouton (Config.UI + "/pause.png", Action.PAUSE, Config.UI + "/play.png");
			this.addBouton (Config.UI + "/showg.png", Action.GRILLE, Config.UI + "/hideg.png");
			this.addBouton (Config.UI + "/grilleplus.png", Action.GRILLE_PLUS);
			this.addBouton (Config.UI + "/grillemoins.png", Action.GRILLE_MOINS);
			this.addBouton (Config.UI + "/A.png", Action.CONFIG);
		}

		/**
		 * Run le menu [ne sert à rien ?]
		 */
		public void run () {

		}

		/**
		 * Run le menu, affiche les boutons 
		 * et les limites du menu
		 */
		public void draw () {
			foreach (var btn in this.btns) {
				if (btn != null) {
					if (btn is Bouton) {
						aff.draw_button ((Bouton) btn);
					} else {
						aff.draw_label ((Label) btn);
					}
				}
			}
			
			// Dessine les lignes de séparation du menu
			aff.draw_line (0,0, Affichage.SCREEN_WIDTH,0);
			aff.draw_line (0,BTN_HEIGHT, Affichage.SCREEN_WIDTH, BTN_HEIGHT);
		}

		/**
		 * Retourne le bouton qui contient 
		 * la position (x,y), et null si 
	     * aucun bouton ne contient celle-ci 
		 */
		public Bouton? getBtnPos (int x, int y) {
			foreach (var b in this.btns) {
				/**
				 * Si le pointeur est dans le rectangle 
				 * du bouton
				 */
				if (b != null && b is Bouton && b.contains (x,y))
				{
					return (Bouton) b;
				}
			}
			return null;
		}

		/**
		 * Ajoute un bouton au menu
		 */
		public int addBouton (string src, Action a, string src2 = "") {
			this.btns[nbr] = new Bouton.pos (src,a, BTN_WIDTH * nbr , 0, src2);
			nbr++;
			return nbr-1;
		}
		

		/*public int addLabel (string start) {

			var l = new Label (start,BTN_WIDTH * nbr, 0);
			this.btns[nbr] = l;
			this.nbr++;
			return nbr - 1;
		}*/
	}
}
