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
using SDL; // Écran
using SDLGraphics; // Géométrie
using SDLImage; // Images

/**
 * Gestion de l'affichage de la fenêtre
 */
public class Affichage : Object {
	
	public static int SCREEN_WIDTH = 800;
	public static int SCREEN_HEIGHT = 300;
	public static int32 COULEUR_TEXTE = 65023;
	
	/**
	 * Variable statique qui contient l'image des cellules
	 */
	//public static Surface SPRITE_CELLULE = SDLImage.load (Config.SPRITE + "/cell.png");

	private const int SCREEN_BPP = 32; // Profondeur de couleur de l'écran 

	// L'écran lui-même
	private weak SDL.Screen screen; 

	// La surface de fond d'écran
	private SDL.Surface background;
	
	/**
	 * Constructeur 
	 */
	public Affichage () {
		this.init_video ();
	}

	/**
	 * Efface l'écran
	 */
	public void clearscr ()
	{
		screen.fill (null,Main.COULEUR_FOND);
	}
	
	/**
	 * Efface un rectangle de l'écran
	 */
	public void clearrect (Rectangle r) {
		screen.fill (r.toRect (), Main.COULEUR_FOND);
	}

	/**
	 * Raffraichit l'écran
	 */
	public void affiche () 
	{
		screen.flip ();
	}

	/**
	 * Affiche l'élément e
	 */
	public void draw_elem (Rectangle e)
	{
		SDLGraphics.Rectangle.fill_rgba (screen, (int16) e.x, (int16) e.y, (int16) (e.x + e.w), (int16) (e.h + e.y),0, 0xFF, 0, 0xFF);
	}
	
	/**
	 * Affiche un bouton b
	 */
	public void draw_button (Menu.Bouton b) {
		if (b.active) {
			b.imgSelect.blit (null, screen, b.toRect ());
		} else {
			b.img.blit (null, screen, b.toRect ());
		}
		draw_line (b.x + b.w, b.y, b.x + b.w, b.y + b.h - 1);
	}
	
	/**
	 * Affiche un label l
	 */
	public void draw_label (Menu.Label l) {
		if (l.img != null) {
			l.img.blit (null, screen, l.toRect ());
		}
		draw_text (l.x + (l.w / 2) - 10 * l.text.length / 2, (l.y + l.h / 2),l.text);
		draw_line (l.x + l.w, l.y, l.x + l.w, l.y + l.h - 1);
	}
	
	/**
	 * Affiche une cellule c
	 */
	public void draw_cell (Cellule.Cellule c) {
		//SPRITE_CELLULE.blit (null, screen, c.toRect ());
		// draw_elem (c);
		
		int bleu = c.mut * 25;
		bleu = (bleu > 255) ? 255 : bleu;
		
		int vert = 255 - c.gen * 10;
		
		
		
		SDLGraphics.Rectangle.fill_rgba (
			screen, (int16) c.x, (int16) c.y, (int16) (c.x + Cellule.C_WIDTH), (int16) (Cellule.C_HEIGHT + c.y),
			255, (uchar) vert,(uchar) bleu, 255);
	}  

	/**
	 * Affiche la cellule e avec une croix dessus …_
	 */
	public void draw_cell_dead (Cellule.Cellule e) {
		//SPRITE_CELLULE.blit (null, screen, e.toRect ());
		draw_elem (e);
		this.draw_line (e.x, e.y, e.x + e.w, e.y + e.h);
		this.draw_line (e.x + e.w, e.y, e.x, e.y + e.h);
	}

	/**
	 * Dessine une ligne du point (x1,y1) au point (x2,y2)
	 */
	public void draw_line (double x1, double y1, double x2, double y2, int32 couleur_ligne = Main.COULEUR_LIGNE)
	{
	
		Line.color (screen, (int16) x1, (int16) y1, (int16) x2, (int16) y2 , couleur_ligne);
		
		// Line.rgba (screen, (int16) x1, (int16) y1, (int16) x2, (int16) y2, Main.COULEUR_LIGNE[0], Main.COULEUR_LIGNE[1], Main.COULEUR_LIGNE[2], 0xFF);
	}
	
	/**
	 * Affiche du texte 
	 */
	public void draw_text (double x, double y, string text, int32 couleur = COULEUR_TEXTE) {
		Text.color (screen, (int16) x, (int16) y, text, couleur);
	}

	/**
	 * Initialise la vidéo
	 */
	private void init_video () {
		uint32 video_flags = SurfaceFlag.DOUBLEBUF
							| SurfaceFlag.HWACCEL
							| SurfaceFlag.HWSURFACE;

		screen = Screen.set_video_mode (SCREEN_WIDTH, SCREEN_HEIGHT,
						SCREEN_BPP, video_flags);
						
		if (screen == null) {
			stderr.printf ("Impossible de charger l'écran.\n");
		}

		SDL.WindowManager.set_caption ("TPE : Simulation Cellules", "");

		background = new SDL.Surface.RGB (video_flags, SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_BPP, 0,0,0,0);
	}
}
