﻿/*
Copyright (c) 2011 Jeroen Beckers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package be.dauntless.astar.basic2d
{
	import be.dauntless.astar.core.IAstarTile;
	import be.dauntless.astar.core.IMap;
	import be.dauntless.astar.core.PathRequest;

	import flash.geom.Point;

	/**
	 * A simple Map implementation for the IMap interface
	 * @author Jeroen Beckers
	 */
	public class Map implements IMap
	{
		private const diagonalMultiplier:Number = 1.4;
		private const normalMultiplier:Number = 1;
		private var _map : Array;
		private var _width : int;
		private var _length : int;
		private var _defaultCost:int;
		
		//the heuristic to be used
		private var _heuristicName:String;
		private var _heuristicFunction:Function;
		
		/**
		 * Diagonal heuristic. The following formula is used:
		 * 
		 * H = Math.max(Math.abs(end.x - start.x), Math.abs(end.y - start.y));
		 */
		public static const DIAGONAL_HEURISTIC:String = "diagonalHeuristic";
		
		/**
		 * Horizontal heuristic. This is the manhattan heuristic. The following formula is used:
		 * 
		 * H = (end.x - start.x) + (end.y - start.y)
		 */
		public static const MANHATTAN_HEURISTIC:String = "manhattanHeuristic";
		
		/**
		 * No heuristic. When no heuristic is used, A* will behave like a breadth-first search algorithm
		 */
		public static const NO_HEURISTIC:String = "noHeuristic";

		
		/**
		 * Creates a new Map object with the specified width en height
		 * 
		 * @param width The width of the map
		 * @param height The height of the map
		 */
		public function Map(width:int, length:int, defaultCost:int = 1)
		{
			_width = width;
			_length = length;
			
			_map = new Array(_width * _length);
			
			_defaultCost = defaultCost;
			
			heuristic = DIAGONAL_HEURISTIC;
		}
		
		/**
		 * Returns the IPositionTile at the given location
		 * 
		 * @param position	The point specifing the location for the tile
		 * @return IPositionTile at the given location
		 */
		
		public function getTileAt(position : Point) : IPositionTile
		{
			if(isValidPosition(position))
			{
				return _map[calcIndex(position)];
			}
			return null;
		}
		
		/**
		 * Sets the given tile at the given location
		 * 
		 * @param tile		The tile to place in the map
		 */
		public function setTile(tile : IPositionTile) : void
		{
			var pos:Point = tile.getPosition();
			if(isValidPosition(pos))
			{
				_map[calcIndex(pos)] = tile;
			}
		}
		
		/**
		 * Calculates the array index for the given point
		 */
		private function calcIndex(pt:Point):int
		{
			return pt.x * _length + pt.y;
		}
		
		/**
		 * Returns the size of this map
		 */
		
		private function getSize():Point
		{
			return  new Point(this._width, this._length);
		}
		
		/**
		 * Returns whether or not the given position is located within the map
		 * 
		 * @param position The position to check
		 * 
		 * @return A boolean indicating if the given position is located within the map
		 */
		private function isValidPosition(position:Point):Boolean
		{
			if(_map == null) return false;
			if(position.x < 0 || position.y < 0) return false;
			
			var size:Point = getSize();
			
			return position.x < size.x && position.y < size.y;
		}
		
		/**
		 * Sets the heuristic to be used. See Map.DIAGONAL_HEURISTIC, Map.HORIZONTAL_HEURISTIC and Map.NO_HEURISTIC for more information
		 * 
		 * @param heuristic		The heuristic that will be used
		 */
		
		public function set heuristic(heuristic:String):void
		{
			if(heuristic == DIAGONAL_HEURISTIC)
			{
				_heuristicFunction = diagonalHeuristic;
				_heuristicName = heuristic;
			}
			else if(heuristic == MANHATTAN_HEURISTIC)
			{
				_heuristicFunction = manhattanHeuristic;
				_heuristicName = heuristic;
			}
			else if(heuristic == NO_HEURISTIC)
			{
				_heuristicFunction = noHeuristic;
				_heuristicName = heuristic;
			}
		}
		
		/**
		 * Returns the heuristic that is currently being used
		 */
		public function get heuristic():String
		{
			return _heuristicName;	
		}
		
		/**
		 * Returns a list with the neighbours of the given tile.
		 * 
		 * @param position The position of the tile to get the neighbours of
		 * 
		 * @return A Vector containing all the neighbouring tiles
		 */
	
		public function getNeighbours(tile:IAstarTile) : Vector.<IAstarTile>
		{
			var position:Point = (tile as IPositionTile).getPosition();
			
			var x:Number = position.x;
			var y:Number = position.y;
			
			var neighbours:Vector.<IAstarTile> = new Vector.<IAstarTile>();
			if(this.isValidPosition(new Point(x-1, y-1))) neighbours.push(this.getTileAt(new Point(x-1, y-1)));
			if(this.isValidPosition(new Point(x-1, y))) neighbours.push(this.getTileAt(new Point(x-1, y)));
			if(this.isValidPosition(new Point(x-1, y+1))) neighbours.push(this.getTileAt(new Point(x-1, y+1)));
			if(this.isValidPosition(new Point(x, y-1))) neighbours.push(this.getTileAt(new Point(x, y-1)));
			if(this.isValidPosition(new Point(x, y+1))) neighbours.push(this.getTileAt(new Point(x, y+1)));
			if(this.isValidPosition(new Point(x+1, y-1))) neighbours.push(this.getTileAt(new Point(x+1, y-1)));
			if(this.isValidPosition(new Point(x+1, y))) neighbours.push(this.getTileAt(new Point(x+1, y)));
			if(this.isValidPosition(new Point(x+1, y+1))) neighbours.push(this.getTileAt(new Point(x+1, y+1)));
			
			return neighbours;
		}
		
		
		
		/**
		 * Checks if the given points are diagonal to eachother.
		 * 
		 * @param from 	The first point
		 * @param to	The second point
		 * 
		 * @return A boolean indicating if the given tiles are diagonal to eachother
		 */
		public function isDiagonal(from:IAstarTile, to:IAstarTile) : Boolean
		{
			var fromPos:Point = (from as IPositionTile).getPosition();
			var toPos:Point = (to as IPositionTile).getPosition();
			return fromPos.x != toPos.x && fromPos.y != toPos.y;
		}
		
		
		/**
		 * Returns the distance between two tiles. This distance is multiplied with the cost of the target tile to get its final G cost.
		 */
		public function getDistance(fromTile:IAstarTile, toTile:IAstarTile):Number
		{
			var from:Point = (fromTile as IPositionTile).getPosition();
			var to:Point = (toTile as IPositionTile).getPosition();
			
			//if they're in the same row or column, they're one appart
			if(from.x == to.x || from.y == to.y)
			{
				return normalMultiplier;
			}
			//otherwise, it's diagonal
			return diagonalMultiplier;
		}
		
		
		/**
		 * Returns the heuristic for the given start tile to the end.
		 */
		public function getHeuristic(tile:IAstarTile, req:PathRequest):Number
		{
			return _heuristicFunction((tile as IPositionTile).getPosition(), (req.getEnd() as IPositionTile).getPosition());
		}
		
		
		
		// HEURISTIC METHODS
		private function noHeuristic( ... args):Number
		{
			return 0;
		}
		
		private function diagonalHeuristic(start:Point, end:Point):Number
		{
			var xd:int = Math.abs(end.x - start.x);
			var yd:int = Math.abs(end.y - start.y);
			if(xd > yd)
			{
				return diagonalMultiplier * _defaultCost * yd + normalMultiplier * _defaultCost * (xd - yd);
			}
			else
			{
				return diagonalMultiplier * _defaultCost * xd + normalMultiplier * _defaultCost * (yd - xd);
			}
		}
		
		private function manhattanHeuristic(start:Point, end:Point):Number
		{
			return ((end.x - start.x) + (end.y - start.y)) * _defaultCost;
		}
			
	}
}
