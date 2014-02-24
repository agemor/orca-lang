package elsa.debug;

/**
 * 디버거
 * 
 * @author 김 현준
 */
class Debug {
	
	/**
	 * 에러 표시를 허용하는지의 여부
	 */
	public static var supressed:Bool = false;
	public static var errorReported:Bool = false;
	
	/**
	 * 에러를 출력한다.
	 * 
	 * @param	errorType
	 * @param	errorMessage
	 * @param	lineNumber
	 */
	public static function reportError(errorType:String, errorMessage:String, lineNumber:Int = 1):Void {
		if (!supressed) print(errorType + " :" + errorMessage + " at " + Std.string(lineNumber));
		errorReported = true;
	}
	
	public static function print(message:Dynamic):Void {
		Sys.println(message);
	}
	
	/**
	 * 잠시 에러 출력을 중지한다.
	 * 
	 * @param	status
	 */
	public static function supressError(status:Bool):Void {
		supressed = status;
	}
	
}