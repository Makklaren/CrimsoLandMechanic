package {
	import flash.events.Event;
    import flash.geom.Point;

    public class MapCellEvent extends Event
	{
		public static const INSTALL_NEW_CELL:String = "install_new_cell";
        private var _positionCell:Point;
		private var _type:String;

		public function MapCellEvent(type:String, positionCell:Point, bubbles:Boolean = false, cancelable:Boolean = true)
		{
			_type = type;
            _positionCell = positionCell;
			super(type, bubbles, cancelable);
		}

		public function get positionCell():Point
		{
			return _positionCell;
		}

		public override function clone():Event
		{
			return new MapCellEvent(_type, _positionCell);
		}

		public override function toString():String
		{
			return formatToString("AlarmEvent", "type", "message", "bubbles", "cancelable", "eventPhase");
		}
	}
}
