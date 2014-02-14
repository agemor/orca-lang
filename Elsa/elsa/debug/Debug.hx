package elsa.debug;

/**
 * 디버거
 * 
 * @author 김 현준
 */
class Debug {
	
	public static var supressed:Bool = false;
	
	public static function report(errorType:String, errorMessage:String, lineNumber:Int = 1):Void {
		if(!supressed) trace(errorType + ":" + errorMessage + " at " + Std.string(lineNumber));
	}
	
	public static function supressError(status:Bool):Void {
		supressed = status;
	}
	
}