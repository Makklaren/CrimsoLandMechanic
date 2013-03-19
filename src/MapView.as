package
{
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class MapView extends ExtendedSprite
    {
        private var _dataMap:Array;
        private var _cellMap:Array;

        public function MapView(dataMap:Array)
        {
            _dataMap = dataMap;
            _cellMap = [];
            super();
        }

        override protected function init():void
        {
            var shiftX:Number = 0;
            var shiftY:Number = 0;

            for (var lineNumber:Number = 0; lineNumber < _dataMap.length; lineNumber++)
            {
                _cellMap[lineNumber] = [];

                for (var rowNumber:Number = 0; rowNumber < (_dataMap[lineNumber] as Array).length; rowNumber++)
                {
                    var cellView:CellView = new CellView(new Point(20, 20), _dataMap[lineNumber][rowNumber]);
                    cellView.x = shiftX;
                    cellView.y = shiftY;
                    addChild(cellView);
                    _cellMap[lineNumber][rowNumber] = cellView;
                    shiftX += cellView.width;
                }
                shiftX = 0;
                shiftY += cellView.height;
            }

            addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
        }

        private function onClick(event:MouseEvent):void
        {
            var cellView:CellView = event.target as CellView;
            dispatchEvent(new MapCellEvent(MapCellEvent.INSTALL_NEW_CELL, getPositionToCell(cellView)));
        }

        public function showPath(path:Array):void
        {
            for (var i:Number = 0; i < path.length; i++)
            {
                var node:Point = path[i];
                _cellMap[node.x][node.y].showMarker();
            }

        }

        public function getPositionToCell(cell:CellView):Point
        {
            var position:Point;
            for (var lineNumber:Number = 0; lineNumber < _dataMap.length; lineNumber++)
            {
                var rowNumber:int = (_cellMap[lineNumber] as Array).indexOf(cell);

                if(rowNumber != -1)
                {
                    position = new Point(lineNumber, rowNumber);
                    break;
                }
            }

            return position;
        }

        public function getPositionCellCoordinates(coordinate:Point):Point
        {
            for (var lineNumber:Number = 0; lineNumber < _dataMap.length; lineNumber++)
            {
                for (var rowNumber:Number = 0; rowNumber < (_dataMap[lineNumber] as Array).length; rowNumber++)
                {
                   var cellView:CellView = _cellMap[lineNumber][rowNumber];
                   if(cellView.hitTestPoint(coordinate.x, coordinate.y))
                       return getPositionToCell(cellView);
                }
            }
            return null;
        }

        public function cell(lineNumber:int, rowNumber:int):CellView
        {
            return _cellMap[lineNumber][rowNumber];
        }

        public function get linesNumber():uint
        {
            return _cellMap.length;
        }

        public function get rowsNumber():uint
        {
            return _cellMap[0].length;
        }
    }
}