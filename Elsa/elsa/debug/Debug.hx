package elsa.debug;

/**
 * ...
 * @author 김 현준
 */
class Debug {
	
	public static function report(errorType:String, errorMessage:String, lineNumber:Int = 1):Void {
		trace(errorType + ":" + errorMessage + " at " + cast(lineNumber, String));
	}
	
	
	
}