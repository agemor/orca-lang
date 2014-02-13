package elsa;
import elsa.nlib.NativeFunction;

/**
 * 심볼 클래스
 * 
 * @author 김 현준
 */
class Symbol {
	
	/**
	 * 심볼 데이터
	 */
	public var id:String;
	public var type:String;
	
	/**
	 * 심볼의 메모리 할당 주소
	 */
	public var address:Int;	
	
	public function new() {	}
}

/**
 * 변수 심볼
 */
class Variable extends Symbol {
	
	public var initialized:Bool = false;

	public function new(id:String, type:String) { 
		this.id = id;
		this.type = type;
	}

	/**
	 * 변수가 배열 타입인지 체크한다.
	 * 
	 * @return
	 */
	public function isArray():Bool {
		if (type == "array" || type == "arr")
			return true;
		return false;
	}

	/**
	 * 변수가 리터럴 타입인지 체크한다.
	 * 
	 * @return
	 */
	public function isNumber():Bool {
		if (type == "number" || type == "num")
			return true;
		return false;

	}

	/**
	 * 변수가 리터럴 타입인지 체크한다.
	 * 
	 * @return
	 */
	public function isString():Bool {
		if (type == "string" || type == "str")
			return true;
		return false;

	}
}

/**
 * 함수 심볼
 */
class Function extends Symbol {
	
	public var functionEntry:Int;
	public var functionExit:Int;
	
	public var parameters:Array<Variable>;
	
	public var isNative:Bool = false;
	public var nativeFunction:NativeFunction;
	
	public function new(id:String, type:String, parameters:Array<Variable> = null) {
		this.id = id;
		this.type = type;
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

/**
 * 클래스 심볼
 */
class Class extends Symbol {
	
	/**
	 * 클래스 맴버 (함수, 변수)
	 */
	public var members:Array<Symbol>;
	
	public function new(id:String) {
		this.id = id;
	}

	/**
	 * 클래스의 맴버를 검색한다.
	 * 
	 * @param id
	 * @return
	 */
	public function findMemberByID(id:String):Symbol {
		for(i in 0...members.length){
			if (members[i].id == id) {
				return members[i];
			}
		}
		return null;
	}
}

/**
 * 리터럴 심볼
 */
class Literal extends Symbol {
	
	public static var NUMBER:String = "number";
	public static var STRING:String = "string";

	public var value:String;

	public function new(value:String, type:String) {
		this.value = value;
		this.type = type;
	}
}