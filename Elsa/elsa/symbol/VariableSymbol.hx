package elsa.symbol;

/**
 * 변수 심볼
 */
class VariableSymbol extends Symbol {
	
	public var initialized:Bool = false;

	public function new(id:String, type:String) { 
				
		super();
		
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
		if (type == "number" || type == "bool")
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