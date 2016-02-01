package orca.symbol;
import orca.nlib.NativeFunction;

/**
 * 함수 심볼
 */
class FunctionSymbol extends Symbol {
	
	public var functionEntry:Int;
	public var functionExit:Int;
	
	public var parameters:Array<VariableSymbol>;
	
	public var isRecursive:Bool = false;
	
	public var isNative:Bool = false;
	public var nativeFunction:NativeFunction;
	
	public function new(id:String, type:String, parameters:Array<VariableSymbol> = null) {
				
		super();
		
		this.id = id;
		this.type = type;
		this.parameters = parameters;
	}
	
	/**
	 * 함수가 값을 반환하지 않는 지 확인한다.
	 * 
	 * @return
	 */
	public function isVoid():Bool {
		if (type == "void")
			return true;
		return false;
	}
}