package orca.vm;
import orca.debug.Debug;

/**
 * Orcinus Application Programming Interface
 * 
 * @author 김 현준
 */
class Api {

	public function new() {		
	}
	
	public static function print(message:Dynamic):Void {
		Debug.print(message);
	}
	
	public static function whoAmI():Void {
		Debug.print("I am Orca Virtual Machine.");
	}
	
	public static function abs(v:Float):Float {
		return Math.abs(v);
	}
	
	public static function acos(v:Float):Float {
		return Math.acos(v);
	}
	
	public static function asin(v:Float):Float {
		return Math.asin(v);
	}
	
	public static function atan(v:Float):Float {
		return Math.atan(v);
	}
	
	public static function atan2(y:Float, x:Float):Float {
		return Math.atan2(y, x);
	}
	
	public static function ceil(v:Float):Float {
		return Math.ceil(v);
	}
	
	public static function floor(v:Float):Float {
		return Math.floor(v);
	}
	
	public static function round(v:Float):Float {
		return Math.round(v);
	}	
	
	public static function cos(v:Float):Float {
		return Math.cos(v);
	}
	
	public static function sin(v:Float):Float {
		return Math.sin(v);
	}	
	
	public static function tan(v:Float):Float {
		return Math.tan(v);
	}
	
	public static function log(v:Float):Float {
		return Math.log(v);
	}
	
	public static function sqrt(v:Float):Float {
		return Math.sqrt(v);
	}
	
	public static function pow(v:Float, exp:Float):Float {
		return Math.pow(v, exp);
	}
	
	public static function exp(v:Float):Float {
		return Math.exp(v);
	}	
	public static function random():Float {
		return Math.random();
	}
	
}