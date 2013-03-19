package com.greensock.plugins
{
	import com.greensock.*;
	import flash.display.*;
	import flash.geom.Rectangle;

	public class MaskPlugin extends TweenPlugin
	{
		public static const API:Number = 1.0;
		protected var _target:DisplayObject;
		protected var _mask:DisplayObject;

		public function MaskPlugin()
		{
			super();
			this.propName = "mask";
			this.overwriteProps = ["mask"];
		}

		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean
		{
			if (!(target is DisplayObject))
			{
				return false;
			}

			_target = target as DisplayObject;

			if (_target.mask != null) {
				_mask = _target.mask;
			}
			else
			{
				var r:Rectangle = _target.getBounds(_target);
				var mask:Sprite = new Sprite();
				mask.graphics.beginFill(0x000000, 0);
				mask.graphics.drawRect(0, 0, r.width + r.x, r.height + r.y);
				mask.graphics.endFill();
				_mask = mask;
				(_target as DisplayObjectContainer).addChild(_mask)
			}

			for (var p:String in value)
			{
				addTween(_mask, p, _mask[p], value[p], p);
			}
			return true;
		}

		override public function set changeFactor(n:Number):void
		{
			updateTweens(n);
			_target.mask = _mask;
		}
	}
}