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
using SDLGraphics;
using Gee;

/**
 * Namespace Cellule
 */
namespace Cellule {
	
	public static int C_HEIGHT = 10;
	public static int C_WIDTH = 10;
	
	public static int C_TPS_DIVISION = 50;
	public static int C_TPS_DIE = 3;
		
	/**
	 * Classe Cellule 
	 */
	public class Cellule : Rectangle {
	

		public int row; // ligne de la cellule
		public int col; // colone de la cellule
		
		public int gen;
		public int mut;

		private weak Gerant g; // pointeur vers le gérant 
		
		/**
		 * Booléen pour savoir si la cellule est 
		 * morte
		 */
		public bool dead;
		
		public int cycles;

		/**
		 * Constructeur 
		 */
		public Cellule (Gerant g, double x = 0, double y = 0) {
			base.vide (); // Crée un rectangle vide (base = classe parente = rectangle)
			
			this.gen = 0;
			this.mut = 0;

			this.g = g; // pointeur vers gérant
			g.nbr_cellules++;
			
			/**
			 * Définit les dimensions en fonction
			 * des valeures des variables dans 
			 * la classe Main
			 */
			this.w = C_WIDTH;
			this.h = C_HEIGHT;
			
			/**
			 * Position de la cellule 
			 */
			this.x = x;
			this.y = y;
		}
		
		~Cellule () {
			// stdout.printf ("Cellule détruite (%d,%d)!\n", row,col);
			g.nbr_cellules--;
		}
		
		/**
		 * Execute un cycle 
		 */
		public void run () {
			this.cycles++; // Ajoute 1 aux cycles
			if (this.cycles % 5 == 0) {
				if (g.UV) {
					int x = GLib.Random.int_range (0,100);
					if (40 < x < 60) {
						this.mut++;
					}
					if (this.mut > 10) {
						this.die ();
					}
				}
			}
			
			if (this.cycles % C_TPS_DIVISION == 0) { // Si le cycle est un multiple du temps de division
				this.gen++;
				/**
				 * On divise
				 */
				g.divisionCellule (this);
				/**
				 * Si le cycle correspond au temps pour mourrir 
				 */
				if (this.cycles >= C_TPS_DIE) {
					this.die (); // On meurt
				}
			}
		}

		/**
		 * Effectue les mutations sur le programme
		 * génétique de la cellule.
		 */
		protected void mute () {
			/**
			 * Code pour muter … pas encore en place
			 */
		}

		/**
		 * Détruit la cellule 
		 */
		public void die () {
			/**
			 * Met juste la variable dead à true.
			 * Normalement on devrait détruire COMPLÉTEMENT
			 * la cellule, mais c'est chiant, avec les trous ;)
			 */
			this.dead = true;
		}
	}
}
