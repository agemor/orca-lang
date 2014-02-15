package elsa.nlib;

import elsa.nlib.NativeFunction;

/**
 * 네이티브 클래스
 * 
 * @author 김 현준
 */
class NativeClass {

	public var className:String;
	public var classMembers:Array<NativeFunction>;
	
	public function new(className:String, classMembers:Array<NativeFunction>) {
			
		this.className = className;
		this.classMembers = classMembers == null ? new Array<NativeFunction>() : classMembers;
	}
	
	/**
	 * 네이티브 클래스에 맴버 함수 추가
	 * 
	 * @param	member
	 */
	public function addMember(member:NativeFunction):Void {
		classMembers.push(member);
	}
	
}