package
{
    import be.dauntless.astar.basic2d.BasicTile;
    import be.dauntless.astar.basic2d.Map;
    import be.dauntless.astar.basic2d.analyzers.WalkableAnalyzer;
    import be.dauntless.astar.core.Astar;
    import be.dauntless.astar.core.AstarEvent;
    import be.dauntless.astar.core.IAstarTile;
    import be.dauntless.astar.core.PathRequest;

    import flash.display.Sprite;
    import flash.geom.Point;

    import math.Amath;
    import math.Avector;

    public class Enemy extends Sprite
    {
        private var _map:Map;
        private var _astar:Astar;
        private var _pathRequest:PathRequest;
        private var _mapCell:Array;
        private var _isWay = false;
        private var _wayIndex = 0; // Текущий шаг
        private var _sprite:Sprite;
        private var _way:Vector.<IAstarTile>;
        protected var _wayTarget:Point; // Текущая цель
        protected var _targetPos:Avector = new Avector();
        protected var _defSpeed:Number = 50; // Скорость
        protected var _rotationSpeed:Number = 15;

        protected var _position:Point; // Текущее положение врага
        protected var _target:Point; // Цель куда должен прийти враг
        protected var _speed:Avector = new Avector();
        protected var _newAngle:Number = 0;
        protected var _oldAngle:Number = 0;
        private var _calcDelay:uint = 0;
        private var _oldPosition:Point = new Point();

        public function Enemy(map:Map, mapCell:Array)
        {
            _map = map;
            _mapCell = mapCell;

            _sprite = new Sprite();
            _sprite.graphics.beginFill(0xBB0000);
            _sprite.graphics.drawCircle(0,0, 10);
            _sprite.graphics.endFill();
            addChild(_sprite);

            for (var yS:Number = 0; yS < _mapCell.length; yS++)
            {
                for (var xS:Number = 0; xS < (_mapCell[yS] as Array).length; xS++)
                {
                    if(_mapCell[yS][xS].hitTestPoint(this.x, this.y))
                    {
                        var startPoint:Point = new Point(yS, xS);
                        trace("startPoint "+startPoint)
                    }

                    if(_mapCell[yS][xS].hitTestPoint(mouseX, mouseY))
                    {
                        var endPoint:Point = new Point(yS, xS);
                        trace("endPoint "+endPoint)
                    }
                }
            }



            _astar = new Astar();
            _astar.addEventListener(AstarEvent.PATH_FOUND, onPathFound);
            _astar.addEventListener(AstarEvent.PATH_NOT_FOUND, onPathNotFound);

            _pathRequest = new PathRequest(IAstarTile(_map.getTileAt(startPoint)), IAstarTile(_map.getTileAt(endPoint)), map);

            _astar.addAnalyzer(new WalkableAnalyzer());
            _astar.getPath(_pathRequest);

        }

        private function onPathNotFound(event:AstarEvent):void
        {
            trace("path not found");
            _isWay = false;
        }

        private function onPathFound(event:AstarEvent):void
        {
            trace("Path was found: ");
         //   for (var i:int = 0; i < event.result.path.length; i++)
         //   {
          //      trace((event.result.path[i] as BasicTile).getPosition());
         //   }

            _way = event.result.path;

            _isWay = true;
            _wayIndex = 0; // Текущий шаг
            setNextTarget(); // Устанавливаем цель
            _sprite.rotation = _newAngle;
        }

        public function update(delta:Number, position:Point):void
        {


           // trace("position "+position)

            if(_oldPosition.x != position.x && _oldPosition.y != position.y)
            {
                _oldPosition = position;

                for (var yS:Number = 0; yS < _mapCell.length; yS++)
                {
                    for (var xS:Number = 0; xS < (_mapCell[yS] as Array).length; xS++)
                    {
                        if(hitTestPoint(_mapCell[yS][xS].x, _mapCell[yS][xS].y))
                        {
                            var startPoint:Point = new Point(yS, xS);
                            trace("startPoint "+startPoint)
                        }

                        if(_mapCell[yS][xS].hitTestPoint(_oldPosition.x, _oldPosition.y))
                        {
                            var endPoint:Point = new Point(yS, xS);
                            trace("endPoint "+endPoint)
                        }
                    }
                }

                if(startPoint == null)
                    startPoint = new Point();

                _pathRequest = new PathRequest(IAstarTile(_map.getTileAt(startPoint)), IAstarTile(_map.getTileAt(endPoint)), _map);

                _astar.getPath(_pathRequest);
            }


            if (_isWay)
            {
                // Разница между текущим и новым углом разворота
                var offsetAngle:Number = _sprite.rotation - _newAngle;

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
                }
                // Двигаем юнита
                var angle:Number = Amath.getAngle(x, y, _targetPos.x, _targetPos.y);
                _sprite.rotation = Amath.toDegrees(angle);
                x += _defSpeed * Math.cos(angle) * delta;
                y += _defSpeed * Math.sin(angle) * delta;

                // Текущее положение
                var cp:Avector = new Avector(x, y);

                // Переходим к новому шагу если текущая цель достигнута
                // Внимание! Чем больше скорость движения врага тем больше должна быть погрешность
                if (cp.equal(_targetPos, _defSpeed / 5))
                {
                    // Обновляем текущие координаты в клеточках
                   // _position.x = Universe.toTile(x);
                   // _position.y = Universe.toTile(y);

                    _wayIndex++;
                    setNextTarget();
                }
            }
        }

        protected function setNextTarget():void
        {
            trace("_wayIndex "+_wayIndex+" _way.length "+_way.length)
            if (_wayIndex == _way.length)
            {
                // Вес маршрут пройден
                _isWay = false;
            }
            else
            {
                // Новая цель
                _wayTarget = (_way[_wayIndex] as BasicTile).getPosition();
                _targetPos.set(_wayTarget.x, _wayTarget.y);
                _targetPos.x += Amath.random(-10, 10);
                _targetPos.y += Amath.random(-10, 10);

                // Расчет угла между текущими координатами и следующей точкой
              //  var angle:Number = Amath.getAngle(x, y, _targetPos.x, _targetPos.y);
                _newAngle = Amath.toDegrees(Amath.getAngle(x, y, _targetPos.x, _targetPos.y));

                // Установка новой скорости
               // _speed.asSpeed(_defSpeed, angle);

                // Разворот спрайта
                //_sprite.rotation = Amath.toDegrees(angle);
            }
        }
    }
}
