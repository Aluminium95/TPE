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
using SDLImage;
using Config;


/**
 * Wrapper pour le SDL Rect :D
 * Permet d'utiliser des doubles
 * pour gérer plus finement les 
 * déplacements 
 */
public abstract class Rectangle : Object {
	public double x;
	public double y;
	public double w;
	public double h;

	/**
	 * Crée le Rectangle à partir
	 * d'un SDL.Rect
	 */
	public Rectangle.width_rect (SDL.Rect r) {
		this.setRect (r);
	}
	
	/**
	 * Crée un Rectangle vide ( toutes les valeurs à 0 )
	 */
	public Rectangle.vide () {
		this.x = 0;
		this.y = 0; 
		this.h = 0;
		this.w = 0;
	}
	
	/**
	 * Crée un rectangle juste avec les 
	 * valeurs w et h (les autres à 0)
	 */
	public Rectangle.menu (int w, int h) {
		this.x = 0;
		this.y = 0;
		this.h = h;
		this.w = w;
	}

	/**
	 * Définit le rectangle à partir 
	 * des dimensions d'un SDL.Rect
	 */
	public void setRect (SDL.Rect r) {
		this.x = r.x;
		this.y = r.y;
		this.w = r.w;
		this.h = r.h;
	}

	/**
	 * Retourne le SDL.Rect correspondant
	 * ( cast de double vers int16 donc
	 * perte de précision )
	 */
	public SDL.Rect toRect () {
		return SDL.Rect () {
				x = (int16) this.x, 
				y = (int16) this.y,
				w = (int16) this.w,
				h = (int16) this.h };
	}

	/**
	 * Retroune vrai si le point (x,y) est contenu
	 * par l'élément 
	 */
	public bool contains (double x, double y) {
		if ( (this.x < x < (this.x + this.w) ) && 
		     (this.y < y < (this.y + this.h) ) )
		{
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Bouge le rectangle avec le vecteur x,y
	 */
	public void move (double x, double y)
	{
		this.y += y;
		this.x += x;
	}
	
	/**
	 * Met le rectangle à la position x,y
	 */
	public void deplace (double x, double y) {
		this.x = x;
		this.y = y;
	}
}
