package orca.nlib;

/**
 * 네이티브 변수
 * 
 * @author 김 현준
 */
class NativeVariable {

	public var variableName:String;
	public var value:String;
	
	public function new(variableName:String, value:String) {
		this.value = value;
		this.variableName = variableName;
	}
	
}