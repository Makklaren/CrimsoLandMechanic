package
{
    import be.dauntless.astar.basic2d.BasicTile;
    import be.dauntless.astar.basic2d.IWalkableTile;
    import be.dauntless.astar.basic2d.Map;
    import be.dauntless.astar.basic2d.analyzers.WalkableAnalyzer;
    import be.dauntless.astar.core.Astar;
    import be.dauntless.astar.core.AstarEvent;
    import be.dauntless.astar.core.IAstarTile;
    import be.dauntless.astar.core.PathRequest;

    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import math.Amath;
    import math.Avector;

    public class Enemy extends ExtendedSprite
    {
        private var _map:Map;
        private var _astar:Astar;
        private var _pathRequest:PathRequest;
        private var _mapView:MapView;
        private var _isWay = false;
        private var _wayIndex = 0; // Текущий шаг
        private var _sprite:Sprite;
        private var _way:Array;
        protected var _wayTarget:Point; // Текущая цель
        protected var _targetPos:Point = new Point();
        protected var _defSpeed:Number = 50; // Скорость
        protected var _rotationSpeed:Number = 15;
        protected var _position:Point; // Текущее положение врага
        protected var _target:Point; // Цель куда должен прийти враг
        protected var _speed:Avector = new Avector();
        protected var _newAngle:Number = 0;
        protected var _oldAngle:Number = 0;
        private var _calcDelay:uint = 0;
        private var _oldPosition:Point = new Point();
        private var _waySprite:Sprite;

        public function Enemy(map:Map, mapView:MapView)
        {
            _map = map;
            _mapView = mapView;
            _defSpeed = Amath.random(20, 80);

            super();
        }

        override protected function init():void
        {
            _sprite = new Sprite();
            _sprite.graphics.beginFill(0xCCCC33);
            _sprite.graphics.drawCircle(0, 0, 10);
            _sprite.graphics.endFill();
            addChild(_sprite);

            var point:Sprite = new Sprite();
            point.graphics.lineStyle(2, 0x666666, 1);
            point.graphics.moveTo(0, 0);
            point.graphics.lineTo(10, 0);
            _sprite.addChild(point);
            _sprite.rotation = 0;
            _sprite.filters = [new GlowFilter(0x000000, 1.0, 2.0, 2, 4,3 )];

            _astar = new Astar();
            _astar.addEventListener(AstarEvent.PATH_FOUND, onPathFound);
            _astar.addEventListener(AstarEvent.PATH_NOT_FOUND, onPathNotFound);

            _mapView.addEventListener(MapCellEvent.INSTALL_NEW_CELL, onInstallNewCell);
        }

        private function onInstallNewCell(event:MapCellEvent):void
        {
            trace("enemy position " + _mapView.getPositionCellCoordinates(new Point(this.x, this.y)) + " new target position " + event.positionCell);

            if (IWalkableTile(_map.getTileAt(event.positionCell)).getWalkable())
            {
                _pathRequest = new PathRequest(IAstarTile(_map.getTileAt(_mapView.getPositionCellCoordinates(new Point(this.x, this.y)))), IAstarTile(_map.getTileAt(event.positionCell)), _map);
                _astar.addAnalyzer(new WalkableAnalyzer(true));
                _astar.getPath(_pathRequest);
            }
        }

        private function onPathNotFound(event:AstarEvent):void
        {
            trace("path not found");
            _isWay = false;
        }

        private function onPathFound(event:AstarEvent):void
        {
            //trace("Path was found: ");
            // _way = event.result.path;

            //  _sprite.rotation = _newAngle;
            _way = [];
            for (var i:int = 0; i < event.result.path.length; i++)
            {
                _way.push((event.result.path[i] as BasicTile).getPosition());
            }

            _isWay = true;
            _wayIndex = 0; // Текущий шаг
            setNextTarget(); // Устанавливаем цель

           // _mapView.showPath(_way);
        }

        public function update(delta:Number):void
        {
            if (_isWay)
            {
                // Разница между текущим и новым углом разворота
                /*       var offsetAngle:Number = _sprite.rotation - _newAngle;

                 // Нормализация разницы углов
                 if (offsetAngle > 180)
                 {
                 offsetAngle = -360 + offsetAngle;
                 }
                 else if (offsetAngle < -180)
                 {
                 offsetAngle = 360 + offsetAngle;
                 }

                 // Плавный разворот еденицы
                 if (Math.abs(offsetAngle) < _rotationSpeed)
                 {
                 _sprite.rotation -= offsetAngle;
                 }
                 else if (offsetAngle > 0)
                 {
                 _sprite.rotation -= _rotationSpeed;
                 }
                 else
                 {
                 _sprite.rotation += _rotationSpeed;
                 }

                 // Если поворот спрайта изменился, перерасчитываем векторную скорость
                 if (_sprite.rotation != _oldAngle)
                 {
                 _speed.asSpeed(_defSpeed, Amath.toRadians(_sprite.rotation));
                 _oldAngle = _sprite.rotation;
                 }*/
                /**/
                /**/
                // Двигаем юнита
                var angle:Number = Amath.getAngle(this.x, this.y, _targetPos.x, _targetPos.y);
                // trace("angle "+angle);
                this.rotation = Amath.toDegrees(angle);
                // trace("this.rotation "+this.rotation);
                this.x += _defSpeed * Math.cos(angle) * delta;
                this.y += _defSpeed * Math.sin(angle) * delta;

                // Переходим к новому шагу если текущая цель достигнута
                // Внимание! Чем больше скорость движения врага тем больше должна быть погрешность
                if ((Amath.equal(_targetPos.x, this.x, _defSpeed / 50) && Amath.equal(_targetPos.y, this.y, _defSpeed / 50)))
                {
                    _wayIndex++;
                    setNextTarget();
                }
            }
        }

        protected function setNextTarget():void
        {
            if (_wayIndex == _way.length)
            {
                _isWay = false;
                trace("this.x "+this.x+" this.y "+this.y)
            }
            else
            {
                // Новая цель
                _wayTarget = _way[_wayIndex];
                var cell:Sprite = _mapView.cell(_wayTarget.x, _wayTarget.y);
                _targetPos = _mapView.localToGlobal(new Point(cell.x, cell.y));

                trace("_targetPos " + _targetPos + " _wayTarget " + _wayTarget);
                // _targetPos.x += Amath.random(-10, 10);
                // _targetPos.y += Amath.random(-10, 10);
            }
        }
    }
}
