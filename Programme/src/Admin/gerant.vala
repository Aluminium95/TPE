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

using Gee; // Conteneurs
using GLib;
using SDL; // Ecran / affichage
using Cellule; // Cellules :D


/**
 * Objet contenant 
 * un tableau de cellules et
 * exposant des fonctions pour gérer
 * ce groupe.
 *	  NÉCESSITE UN GROS CLEAN
 */
public class Gerant : Rectangle {
	
	/**
	 * Propriétés globales 
	 * modifiables par d'autres et universelles
	 */
	public static bool GRILLE_ACTIVE = false;
	public static int GRILLE_WIDTH = 4;
	public static int GRILLE_HEIGHT = 4;
	public static int32 COULEUR_GRILLE = 16645629;
	public static bool DEPL_DIV_ACTIVE = true;

	private Cellule.Cellule?[,] cells; // Tableau de cellules
	private int num_cols; // Nombre de colones
	private int num_rows; // Nombre de lignes
	public int nbr_cellules; // Nombre de cellules
	public int nbr_cellules_mortes;
	public int nbr_cellules_mutees;
	
	public bool UV = false;
	
	private weak Affichage aff; // Pointeur vers l'affichage
	
	protected delegate void MapApply (int row, int col);
	
   	/**
   	 * Constructeur de la simulation 
   	 */
    public Gerant (int x, int y, int w, int h, Affichage aff) {
		base.vide (); // base = parent = rectangle 
		
		/**
		 * Définition des dimensions du rectangle 
		 * De la simulation 
		 */
		this.w = w;
		this.x = x;
		this.y = y;
		this.h = h;
		
		this.aff = aff; // Set du pointeur vers aff

		/**
		 * Calcule du nombre de colones et de lignes 
		 * en fonction de la taille des cellules et des dimensions 
		 */
		num_cols = (int16) this.w / Cellule.C_WIDTH;
        num_rows = (int16) (this.h - 50)/ Cellule.C_HEIGHT;
		
		this.cells = new Cellule.Cellule[num_rows,num_cols]; // Crée le tableau
		
		/**
		 * Remplit le tableau de null 
		 */
		this.apply_cells ((row,col) => {
			this.cells[row,col] = null;
		});
		
		this.addCellRdm (); // Ajoute une cellule de base
    }

	/**
	 * Retourne la cellule qui contient la position
	 * Ou null si la cellule n'existe pas 
	 */
	public Cellule.Cellule? getCell (int x, int y) {
		assert (this.contains (x,y));
		
		int col = (int) ((x - this.x) / Cellule.C_WIDTH);
		int row = (int) ((y - this.y) / Cellule.C_HEIGHT );
		
		return this.cells[row,col];
	}

	/**
	 * Ajoute une cellule à la position x,y
	 * Le curseur doit être dans la simulation
	 * sinon il y a une erreur
	 */
	public void addCell (int x, int y) {
		assert (this.contains (x,y));
		
		int col = (int) ((x - this.x) / Cellule.C_WIDTH);
		int row = (int) ((y - this.y) / Cellule.C_HEIGHT );

		if (this.cells[row,col] == null) {
			this.addNewCellTable (row,col,0);
		}
	}

	/**
	 * S'occupe de créer la bonne cellule à la position donnée
	 */
	private void addNewCellTable (int row, int col, int mut) {
		// S'assure que c'est dans la simulation 
		assert (row < num_rows && col < num_cols && row >= 0 && col >= 0);
		
		if (this.cells[row,col] == null) { // Vérifie qu'il n'y ai pas déjà une cellule dans la case 
			this.cells[row,col] = new Cellule.Cellule (this,col * Cellule.C_WIDTH + this.x,
				                                       row * Cellule.C_HEIGHT + this.y);
			this.cells[row,col].row = row;
			this.cells[row,col].col = col;
			this.cells[row,col].mut = mut;
		} else {
			// Sinon affiche un message d'erreur 
			stdout.printf ("Erreur … malheur !\n");
		}
	}
	
	/**
	 * S'occupe de déplacer une cellule à une nouvelle place 
	 */
	private void mvCellTable (Cellule.Cellule? c, int row, int col) {

		this.cells[row,col] = c;
		if (c != null) {
			this.cells[row,col].row = row;
			this.cells[row,col].col = col;
			this.cells[row,col].deplace (col * Cellule.C_WIDTH + this.x,
				                      row * Cellule.C_HEIGHT + this.y);
		}
	}

	/**
	 * Ajoute une cellule aléatoirement !! Pas pour l'instant
	 */
	public void addCellRdm () {
		var c = new Cellule.Cellule (this);
		bool d = false;

		while (!d) {
			c.move (x + Cellule.C_WIDTH * GLib.Random.int_range (0,num_cols),
			        Cellule.C_HEIGHT * GLib.Random.int_range (0,num_rows) + y);
			
			int col = (int) ((c.x - this.x)/ Cellule.C_WIDTH );
			int row = (int) ((c.y - this.y)/ Cellule.C_HEIGHT);
			
			if (cells[row,col] == null) {
				c.row = row;
				c.col = col;
				this.cells[row,col] = c;
				d = true;
			}
		}
	}

	/**
	 * Supprime la cellule qui contient 
	 * la position 
	 */
	public bool removeCellPos (int x, int y) {
		if (getCell (x,y) != null) {
			getCell (x,y).die ();
			return true;
		}
		return false;
	}
	
	/**
	 * Détruit la cellule
	 */
	public void dellCell (int row, int col) {
		cells[row,col] = null;
	}

	public void dellAllCell () {
		this.apply_cells ((row,col) => {
			//if (this.cells[row,col] != null) {
			//	dellCell (row,col);
			//} else {
				cells[row,col] = null;
			//}
		});
	}	
	
	/**
	 * Fait un tour de boucle de simulation
	 * et affiche les objets
	 */
	public void run () {
		this.apply_cells ((row,col) => {
	        if (cells[row,col] != null) {
				if (cells[row,col].dead == false){
					cells[row,col].run (); 
				}
			}
		});
	}
	
	/**
	 * Affiche les éléments 
	 */
	public void draw () {
		this.apply_cells ((row,col) => {
			if (this.cells[row,col] != null) {
				if (this.cells[row,col].dead == false) {
					aff.draw_cell (this.cells[row,col]);
				} else {
					dellCell (row,col);
				}
			}
		});
		
		int x = 0;
		int y = 0;
		SDL.Cursor.get_state (ref x, ref y);
		
		if (GRILLE_ACTIVE) {
			assert (GRILLE_WIDTH >= 1 && GRILLE_HEIGHT >= 1);
			
			if (this.contains (x,y)) {
			
				int r_x = (int) ((x - this.x) /(Cellule.C_WIDTH * GRILLE_WIDTH ));
				int r_y = (int) ((y - this.y) / (Cellule.C_HEIGHT * GRILLE_HEIGHT));
				
				int count = 0;
				
				for (int row = r_y * GRILLE_HEIGHT; row < (r_y + 1) * GRILLE_HEIGHT && row < num_rows; row++) {
					for (int col = r_x * GRILLE_WIDTH; col < num_cols &&  col < (r_x + 1) * GRILLE_WIDTH; col++) {
						if (cells[row,col] != null && cells[row,col].dead == false) {
							count++;
						}
					} 
				}
			
				aff.draw_text (this.x + Cellule.C_WIDTH * GRILLE_WIDTH * r_x + Cellule.C_WIDTH * GRILLE_WIDTH / 2, 
								this.y + Cellule.C_HEIGHT * GRILLE_HEIGHT * r_y + Cellule.C_HEIGHT * GRILLE_HEIGHT / 2, 
								count.to_string (), 3265);
			}
			
			
			for ( int col = 0; col < num_cols; col += GRILLE_WIDTH) {
				aff.draw_line (this.x + Cellule.C_WIDTH * col, this.y, this.x + Cellule.C_WIDTH * col, this.y + this.h - 50, COULEUR_GRILLE);
		    }
			
			for (int row = 0; row < num_rows; row += GRILLE_HEIGHT) {
				aff.draw_line (this.x, this.y + row * Cellule.C_HEIGHT, this.x + this.w, this.y + row *  Cellule.C_HEIGHT, COULEUR_GRILLE);
			}
		} /*else {
			if (this.contains (x,y)) {
				aff.draw_text (x + 15, y + 15, nbr_cellules.to_string (), 3265);
			}
		}*/
		
		aff.draw_line (this.x,this.y,this.x, this.y + this.h);
		aff.draw_line (this.x + this.w, this.y, this.x + this.w, this.y + this.h);
		aff.draw_line (this.x, this.y + this.h - 50, this.x + this.w, this.y + this.h - 50);
		
		aff.draw_text (this.x + 5, this.y + this.h - 25, this.nbr_cellules.to_string ());
	}

	/**
	 * Crée un clone de la cellule 
	 */
	public void divisionCellule (Cellule.Cellule c) {
		/**
		 * On teste les alentours pour voir
		 * Mettre du random dedans … sinon les structures 
		 * cellulaires sont toujours les mêmes !!
		 */
		
		if (canCreateCell (c.row, c.col - 1)) {
			this.addNewCellTable (c.row, c.col -1, c.mut);
			
		} else if (canCreateCell (c.row, c.col + 1)) {
			this.addNewCellTable (c.row, c.col + 1, c.mut);
			
		} else if (canCreateCell (c.row + 1, c.col)) {
			this.addNewCellTable (c.row + 1, c.col, c.mut);
			
		} else if (canCreateCell (c.row - 1, c.col)) {
			this.addNewCellTable (c.row - 1, c.col, c.mut);
			
		} else if (canCreateCell (c.row -1, c.col + 1)) {
			this.addNewCellTable (c.row - 1, c.col + 1, c.mut);
			
		} else if (canCreateCell (c.row + 1, c.col - 1)) {
			this.addNewCellTable (c.row + 1, c.col - 1, c.mut);
			
		} else if (canCreateCell (c.row - 1, c.col - 1)) {
			this.addNewCellTable (c.row - 1, c.col - 1, c.mut);
			
		} else if (canCreateCell (c.row + 1, c.col + 1)) {
			this.addNewCellTable (c.row + 1, c.col + 1, c.mut);
			
		} else {
			if (DEPL_DIV_ACTIVE) {
				deplRangee (c);
			}
		}
	}
	
	/**
	 * True si la cellule peut être crée ici, 
	 * false sinon
	 */
	public bool canCreateCell (int row, int col) {
		if ( ((0 <= row < num_rows) && (0 <= col < num_cols)) && (cells[row, col] == null) ) {
			return true;
		}
		return false;
	}

	/**
	 * À utiliser quand il n'y a pas de place autour de
	 * la cellule ! 
	 * Ajoute la cellule et déplace les autres autour … -> bug :D
	 * CETTE FONCTION N'EST JAMAIS APPELLÉE : ELLE NE FONCTIONNE PAS !
	 */
	private void deplRangee (Cellule.Cellule c) {
		int x = 0;
		bool reussi = false;
		int cstart = 0;
		
		while (!reussi) { // Tant qu'on a pas réussi … 
			x = GLib.Random.int_range (0,4); // Nombre aléatoire
			
			switch (x) {
				case 0: // Gauche

					for (int colone = 0; colone < c.col - 1; colone++) {
						if (this.cells[c.row,colone] == null) {
							cstart = colone;
						}
					}

					for (int colone = cstart; colone < c.col - 1; colone++) {
						this.mvCellTable (this.cells[c.row,colone + 1], c.row,colone);
					}

					if (c.col - 1 >= 0) {
						this.dellCell (c.row,c.col - 1);
						this.addNewCellTable (c.row, c.col - 1, c.mut);
						reussi = true;
					}
					break;
				case 3: // Droite
					for (int colone = num_cols - 1; colone > c.col + 1; colone--) {
						if (this.cells[c.row,colone] == null) {
							cstart = colone;
						}
					}

					for (int colone = cstart; colone > c.col + 1; colone--) {
						this.mvCellTable (this.cells[c.row,colone - 1], c.row,colone);
					}

					if (c.col + 1 < num_cols) {
						this.dellCell(c.row,c.col + 1);
						this.addNewCellTable (c.row, c.col + 1, c.mut);
						reussi = true;
					}
					break;
				case 1: // Haut

					for (int row = 0; row < c.row - 1; row++) {
						if (this.cells[row,c.col] == null) {
							cstart = row;
						}
					}

					for (int row = cstart; row < c.row - 1; row++) {
						this.mvCellTable (this.cells[row + 1,c.col], row,c.col);
					}

					if (c.row - 1 >= 0) {
						this.dellCell(c.row - 1,c.col);
						this.addNewCellTable (c.row - 1, c.col, c.mut);
						reussi = true;
					}
					break;
				case 2:	// Bas
					for (int row = num_rows - 1; row > c.row + 1; row--) {
						if (this.cells[row,c.col] == null) {
							cstart = row;
						}
					}

					for (int row = cstart; row > c.row + 1; row--) {
						this.mvCellTable (this.cells[row - 1,c.col], row,c.col);
					}

					if (c.row + 1 < num_rows) {
						this.dellCell(c.row + 1,c.col);
						this.addNewCellTable (c.row + 1, c.col, c.mut);
						reussi = true;
					}
					break;
					
			}
		}
	}
	
	/**
	 * True si le pointeur est dans la zone
	 * False sinon
	 */
	public new bool contains (double x, double y) {
		if ( (this.x < x < (this.x + this.w) ) && 
		     (this.y < y < (this.y + this.h - 50) ) )
		{
			return true;
		} else {
			return false;
		}
	}
	
	/** 
	 * Comme map
	 */
	protected void apply_cells (MapApply fn) {
		for (int row = 0; row < num_rows; row ++) {
			for (int col = 0; col < num_cols; col++) {
				fn (row,col);
			}
		}
	}
}
