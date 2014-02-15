package elsa.symbol;

/**
 * 심볼 테이블
 * 
 * @author 김 현준
 */
class SymbolTable {

	/**
	 * 할당 가능한 메모리 주소
	 */
	public var availableAddress:Int = 0;
	
	/**
	 * 로컬 심볼 테이블
	 */
	public var local:Map<String, Symbol>;

	/**
	 * 전역 심볼 테이블
	 */
	public var global:Map<Int, Symbol>;

	/**
	 * 리터럴 테이블
	 */
	public var literal:Array<LiteralSymbol>;
	
	public function new() {
		
		// 맵을 초기화한다.
		local = new Map<String, Symbol>();
		global = new Map<Int, Symbol>();
		literal = new Array<LiteralSymbol>();
	}
	
	/**
	 * 테이블에 심볼을 추가한다. 추가와 동시에 모든 심볼은 고유의 메모리 주소를 할당받는다.
	 * 
	 * @param symbol
	 * @return
	 */
	public function add(symbol:Symbol):Symbol {

		// 맵에 추가한다.
		local.set(symbol.id, symbol);
		global.set(availableAddress++, symbol);

		// 메모리 어드레스 할당
		symbol.address = availableAddress - 1;

		return symbol;
	}

	/**
	 * 로컬 심볼을 취득한다.
	 * 
	 * @param id
	 * @return
	 */
	public function findInLocal(id:String):Symbol {
		return local.get(id);
	}
	
	/**
	 * 전역 심볼을 취득한다.
	 * 
	 * @param id
	 * @return
	 */
	public function findInGlobal(address:Int):Symbol {
		return global.get(address);
	}

	/**
	 * 로컬 심볼을 제거한다.
	 * 
	 * @param id
	 */
	public function removeInLocal(id:String):Void {
		local.remove(id);
	}

	/**
	 * 전역 심볼을 제거한다.
	 * 
	 * @param address
	 */
	public function removeInGlobal(address:Int):Void {
		global.remove(address);
	}

	/**
	 * 주어진 변수 ID의 유효성을 검증한다.
	 * 
	 * @param id
	 * @return
	 */
	public function isValidVariableID(id:String):Bool {
		
		// 로컬 스코프에서 찾을 수 있으면 유효한 id이다.
		if (findInLocal(id) != null)
			if (Std.is(findInLocal(id), VariableSymbol))
				return true;
				
		return false;
	}

	/**
	 * 주어진 함수 ID의 유효성을 검증한다.
	 * 
	 * @param id
	 * @return
	 */
	public function isValidFunctionID(id:String):Bool  {

		// 로컬 스코프에서 찾을 수 있으면 유효한 id이다.
		if (findInLocal(id) != null)
			if (Std.is(findInLocal(id), FunctionSymbol))
				return true;

		return false;
	}

	/**
	 * 주어진 타입이 유효한지 체크한다.
	 * 
	 * @return
	 */
	public function isValidClassID(id:String):Bool  {

		// 리터럴 타입일 경우 항상 유효하다.
		if (id == "number" || id == "string" || id == "array")
			return true;

		// 커스텀 타입일 경우 심볼 테이블에서 찾아 유효성을 검증한다.
		if (findInLocal(id) != null)
			if (Std.is(findInLocal(id), ClassSymbol))
				return true;
				
		return false;
	}

	/**
	 * 리터럴 테이블에 넘겨진 값이 존재하는 경우 그 참조를 리턴하고, 없으면 새로 추가한 후 리턴한다.
	 * 
	 * @param value
	 * @param type
	 * @return
	 */
	public function getLiteral(value:String, type:String):LiteralSymbol {
		
		for (i in 0...literal.length) {
			if (literal[i].type == type && literal[i].value == value)
				return literal[i];
		}

		var newLiteral:LiteralSymbol = new LiteralSymbol(value, type);
		newLiteral.address = availableAddress++;
		literal.push(newLiteral);
		
		return newLiteral;

	}
	
}