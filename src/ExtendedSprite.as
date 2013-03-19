package
{
    import flash.display.Sprite;
    import flash.events.Event;

    public class ExtendedSprite extends Sprite
    {
        public function ExtendedSprite()
        {
            addEventListener(Event.ADDED_TO_STAGE, _init, false, 0, true);
        }

        private function _init(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _init);
            addEventListener(Event.REMOVED_FROM_STAGE, _destroy, false, 0, true);
            init()
        }

        protected function init():void
        {

        }

        private function _destroy(event:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, _destroy);
            destroy()
        }

        protected function destroy():void
        {

        }
    }
}
