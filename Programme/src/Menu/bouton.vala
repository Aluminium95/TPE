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
using SDL;
using SDLImage;

/**
 * Gestion des menus
 */
namespace Menu {
	/**
	 * Actions des menus/boutons
	 */
	public enum Action {
		AJOUTER, UV, SUPPRIMER, CONFIG, GRILLE, PAUSE,
		GRILLE_PLUS, GRILLE_MOINS
	}

	/**
	 * Bouton du menu
	 */
	public class Bouton : Rectangle {

		public Action action;

		public bool active;

		public Surface img; // Image de l'objet
		public SDL.Surface? imgSelect; // Deuxième image
		
		public Bouton (string src, Action a) {
			base.vide ();
			
			this.img = SDLImage.load (src);
			SDL.Rect r = {0,0,0,0};
			this.img.get_cliprect (out r);
			this.setRect (r);
			this.action = a;
		}

		public Bouton.pos (string src, Action a, int x, int y, string src2 = "") {
			base.vide ();
			
			this.img = SDLImage.load (src);
			SDL.Rect r = {0,0,0,0};
			this.img.get_cliprect (out r);
			this.setRect (r);
			
			if (src2 != "") {
				this.imgSelect = SDLImage.load (src2);
			} else {
				this.imgSelect = null;
			}  
			
			this.move (x,y);
			this.action = a;
			this.active = false;
		}
	}

	public class Label : Rectangle {
		public string text {get;set;}
		public SDL.Surface? img;
		
		public Label (string start, double x, double y) {
			base.vide ();
			this.text = start;
			this.x = x;
			this.y = y;
			this.w = BTN_WIDTH;
			this.h = BTN_HEIGHT;
		}
		
		public void setImg (string src) {
			this.img = SDLImage.load (src);
		}
	}
}
