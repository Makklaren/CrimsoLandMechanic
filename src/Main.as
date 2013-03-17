package
{
    import be.dauntless.astar.basic2d.BasicTile;
    import be.dauntless.astar.basic2d.IPositionTile;
    import be.dauntless.astar.basic2d.Map;
    import be.dauntless.astar.basic2d.analyzers.WalkableAnalyzer;
    import be.dauntless.astar.core.Astar;
    import be.dauntless.astar.core.AstarEvent;
    import be.dauntless.astar.core.IAstarTile;
    import be.dauntless.astar.core.PathRequest;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.utils.getTimer;

    public class Main extends Sprite
    {
        private var dataMap:Array;
        private var map:Map;
        private var astar:Astar;
        private var _mapCell:Array = [];

        private var req:PathRequest;
        private  var text:TextField;
        private  var text2:TextField;
        private var _spriteMap:Sprite;

        private var _enemyes:Array = [];

        private var _deltaTime:Number = 0; // Текущее delta время
        private var _lastTick:int = 0; // Последний тик таймера (для расчета нового delta времени)
        private var _maxDeltaTime:Number = 0.03;

        private var _position:Point = new Point();

        public function Main()
        {
            dataMap = [
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            ];

            _spriteMap = new Sprite();
            addChild(_spriteMap);

            createGrid();

            map = new Map((dataMap[0] as Array).length, dataMap.length);
            for (var y:Number = 0; y < dataMap.length; y++)
            {
                for (var x:Number = 0; x < (dataMap[y] as Array).length; x++)
                {
                    map.setTile(new BasicTile(1, new Point(x, y), (dataMap[y][x] == 0)));
                }
            }

            for(var item:int = 0; item < 1; item++)
            {
                var enemy:Enemy = new Enemy(map, _mapCell);
                enemy.x = Math.random() * 100;
                enemy.y = Math.random() * 200;
                _spriteMap.addChild(enemy);
                _enemyes.push(enemy);
            }



           /* var button:Sprite = new Sprite();
            button.graphics.beginFill(0xAA0000);
            button.graphics.drawRect(0, 0, 60, 20);
            button.graphics.endFill();
            button.x = 350;
            button.y = 20;
            button.buttonMode = true;
            button.addEventListener(MouseEvent.CLICK, onClick);
            addChild(button);

            text = new TextField();
            text.border = true;
            text.type = TextFieldType.INPUT;
            text.x = 350;
            text.y = 50;
            text.height = 20;
            addChild(text);

            text2 = new TextField();
            text2.border = true;
            text2.type = TextFieldType.INPUT;
            text2.x = 350;
            text2.y = 80;
            text2.height = 20;
            addChild(text2);*/

            //create a new map and fill it with BasicTiles


            astar = new Astar();
            astar.addEventListener(AstarEvent.PATH_FOUND, onPathFound);
            astar.addEventListener(AstarEvent.PATH_NOT_FOUND, onPathNotFound);

            req = new PathRequest(IAstarTile(map.getTileAt(new Point(0, 0))), IAstarTile(map.getTileAt(new Point(5, 5))), map);

            addEventListener(Event.ENTER_FRAME, render);

            _spriteMap.addEventListener(MouseEvent.MOUSE_MOVE, onMove);

        }

        private function onMove(event:MouseEvent):void
        {
            _position = new Point(event.localX, event.localY);
        }

        private function render(event:Event):void
        {
            // Рассчет delta времени
            _deltaTime = (getTimer() - _lastTick) / 1000;
            _deltaTime = (_deltaTime > _maxDeltaTime) ? _maxDeltaTime : _deltaTime;
            for each(var enemy:Enemy in _enemyes)
            {
                enemy.update(_deltaTime, _position);
            }

            _lastTick = getTimer();
        }



        /*private function onClick(event:MouseEvent):void
        {
            dataMap[int(text.text)][int(text2.text)] = 1;
            var t:IPositionTile = map.getTileAt(new Point(int(text.text),int(text2.text)));
            map.setTile(new BasicTile(1, t.getPosition(), (dataMap[int(text.text)][int(text2.text)] == 0)));

            deleteGrid();
            createGrid();
            astar.addAnalyzer(new WalkableAnalyzer());
            astar.getPath(req);

        }*/

        private function createGrid():void
        {
            var shiftX:Number = 0;
            var shiftY:Number = 0;

            for (var y:Number = 0; y < dataMap.length; y++)
            {
                _mapCell[y] = [];
                for (var x:Number = 0; x < (dataMap[y] as Array).length; x++)
                {
                    var cell:Sprite = new Sprite();
                   if(dataMap[y][x] == 0)
                       cell.graphics.beginFill(0x00AA00);

                    if(dataMap[y][x] == 1)
                        cell.graphics.beginFill(0x333333);

                    cell.graphics.drawRect(0, 0, 20, 20);
                    cell.graphics.endFill();
                    cell.x = shiftX;
                    cell.y = shiftY;
                    cell.mouseEnabled = false;
                    _spriteMap.addChild(cell);
                    _mapCell[y][x] = cell;

                    shiftX += cell.width;
                }
                shiftX = 0;

                shiftY += cell.height;
            }
        }

        private function deleteGrid():void
        {
            for (var y:Number = 0; y < _mapCell.length; y++)
            {
                for (var x:Number = 0; x < (_mapCell[y] as Array).length; x++)
                {
                    if(_mapCell[y][x].parent)
                        removeChild(_mapCell[y][x]);
                }
            }
        }

        private function onPathNotFound(event:AstarEvent):void
        {
            trace("path not found");
        }


        private function onPathFound(event:AstarEvent):void
        {
            trace("Path was found: ");
            for (var i:int = 0; i < event.result.path.length; i++)
            {
                var p:Point = (event.result.path[i] as BasicTile).getPosition();
                removeChild(_mapCell[p.y][p.x]);
                trace((event.result.path[i] as BasicTile).getPosition());
            }
        }
    }
}
