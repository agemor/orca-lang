package elsa.vm;

/**
 * Orcinus Application Programming Interface
 * 
 * @author 김 현준
 */
class OrcinusAPI {

	public function new() {
		
	}
	
	public static function print(message:Dynamic):Void {
		trace(message);
	}
	
	public static function whoAmI():Void {
		trace("I am Orca Virtual Machine.");
	}
	
}