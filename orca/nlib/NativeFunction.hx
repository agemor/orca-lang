package orca.nlib;

/**
 * 네이티브 함수
 * 
 * @author 김 현준
 */
class NativeFunction {

	public var functionName:String;
	public var parameters:Array<String>;
	public var returnType:String;

	public var assembly:String;
	
	public function new(functionName:String, parameters:Array<String>, returnType:String = "void") {
		this.functionName = functionName;
		this.parameters = parameters;
		this.returnType = returnType;
		
		this.assembly = "";
	}
	
	/**
	 * 함수에 어셈블리 명령 쓰기
	 * 
	 * @param	code
	 */
	public function write(code:String):Void {
		if (assembly != "")
			this.assembly += "\n" + code;
		else
			this.assembly += code;

		this.assembly = StringTools.trim(assembly);
	}
	
}