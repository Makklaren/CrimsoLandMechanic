package
{
    import com.greensock.TweenMax;

    import flash.display.Sprite;
    import flash.geom.Point;

    public class CellView extends ExtendedSprite
    {
        private var _size:Point;
        private var _cost:int;
        private var _marker:Sprite;

        public function CellView(size:Point, cost:int)
        {
            _size = size;
            _cost = cost;
            super();
        }

        override protected function init():void
        {
           // mouseEnabled = false;
            mouseChildren = false;

            var background:Sprite = new Sprite();
            background.graphics.beginFill(0x000000);
            background.graphics.drawRect(-_size.x/2, -_size.y/2, _size.x, _size.y);
            background.graphics.endFill();
            addChild(background);

            var cell:Sprite = new Sprite();
            if(_cost == 0)
                cell.graphics.beginFill(0x00AA00);
            if(_cost == 1)
                cell.graphics.beginFill(0x333333);
            cell.graphics.drawRect(-(_size.x-2)/2, -(_size.y-2)/2, _size.x - 2, _size.y - 2);
            cell.graphics.endFill();
            background.addChild(cell);

            _marker = new Sprite();
            _marker.graphics.beginFill(0xFF0000);
            _marker.graphics.drawCircle(0, 0, 5);
            _marker.graphics.endFill();
            cell.addChild(_marker);
            _marker.alpha = 0;
        }

        public function showMarker():void
        {
            TweenMax.to(_marker, 1, {alpha: 1});
            TweenMax.delayedCall(10, hideMarker);
        }

        public function hideMarker():void
        {
            TweenMax.to(_marker, 1, {alpha: 0});
        }
    }
}