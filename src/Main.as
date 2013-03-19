package
{
    import be.dauntless.astar.basic2d.BasicTile;
    import be.dauntless.astar.basic2d.Map;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.getTimer;

    import math.Amath;

    public class Main extends Sprite
    {
        private var dataMap:Array;
        private var map:Map;
        private var _enemyes:Array = [];
        private var _deltaTime:Number = 0; // Текущее delta время
        private var _lastTick:int = 0; // Последний тик таймера (для расчета нового delta времени)
        private var _maxDeltaTime:Number = 0.03;
        private var _position:Point = new Point();
        private var _mapView:MapView;

        public function Main()
        {
            dataMap = [
                [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0],
                [0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0],
                [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0],
                [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
                [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
                [0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
                [0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0],
                [1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
                [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0],
                [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
                [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            ];

            _mapView = new MapView(dataMap);
            _mapView.x = 30;
            _mapView.y = 20;
            addChild(_mapView);

            map = new Map((dataMap[0] as Array).length, dataMap.length);
            for (var y:Number = 0; y < dataMap.length; y++)
            {
                for (var x:Number = 0; x < (dataMap[y] as Array).length; x++)
                {
                    map.setTile(new BasicTile(dataMap[y][x], new Point(y, x), (dataMap[y][x] == 0)));
                }
            }

            for (var item:int = 0; item < 100; item++)
            {
                var enemy:Enemy = new Enemy(map, _mapView);
                enemy.x = Amath.random(0,  _mapView.linesNumber - 2) * 20 + 30;
                enemy.y = Amath.random(0,  _mapView.rowsNumber - 2) * 20 + 20;
                addChild(enemy);
                _enemyes.push(enemy);
            }

            addEventListener(Event.ENTER_FRAME, render);
        }

        private function move(event:MouseEvent):void
        {
            trace("x: "+event.stageX+" y: "+event.stageY);
        }

        private function render(event:Event):void
        {
            _deltaTime = (getTimer() - _lastTick) / 1000;
            _deltaTime = (_deltaTime > _maxDeltaTime) ? _maxDeltaTime : _deltaTime;

            for each(var enemy:Enemy in _enemyes)
                enemy.update(_deltaTime);

            _lastTick = getTimer();
        }
    }
}