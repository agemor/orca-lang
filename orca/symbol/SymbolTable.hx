package orca.symbol;

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
	public function assignAddress():Int {
		return availableAddress++;
	}
	
	/**
	 * 심볼 테이블
	 */
	public var variables:Array<VariableSymbol>;
	public var functions:Array<FunctionSymbol>;
	public var classes:Array<ClassSymbol>;
	public var literals:Array<LiteralSymbol>;
	
	public function new() {
		
		// 맵을 초기화한다.
		variables = new Array<VariableSymbol>();
		functions = new Array<FunctionSymbol>();
		classes = new Array<ClassSymbol>();
		literals = new Array<LiteralSymbol>();
	}
	
	/**
	 * 테이블에 심볼을 추가한다. 추가와 동시에 모든 심볼은 고유의 메모리 주소를 할당받는다.
	 * 
	 * @param symbol
	 * @return
	 */
	public function add(symbol:Symbol):Symbol {
		
		// 메모리 어드레스 할당
		symbol.address = assignAddress();
		
		// 심볼의 타입에 따라 분류하여 추가한다.
		if (Std.is(symbol, VariableSymbol))
			variables.push(cast(symbol, VariableSymbol));
		else if (Std.is(symbol, FunctionSymbol))
			functions.push(cast(symbol, FunctionSymbol));
		else if (Std.is(symbol, ClassSymbol))
			classes.push(cast(symbol, ClassSymbol));
		else if (Std.is(symbol, LiteralSymbol))
			literals.push(cast(symbol, LiteralSymbol));

		return symbol;
	}
	
	/**
	 * 테이블 내의 심볼을 제거한다.
	 * 
	 * @param symbol
	 * @return
	 */
	public function remove(symbol:Symbol):Symbol {
		
		// 심볼의 타입에 따라 분류하여 삭제한다.
		if (Std.is(symbol, VariableSymbol)) {
			variables.remove(cast(symbol, VariableSymbol));
		}else if (Std.is(symbol, FunctionSymbol))
			functions.remove(cast(symbol, FunctionSymbol));
		else if (Std.is(symbol, ClassSymbol))
			classes.remove(cast(symbol, ClassSymbol));
		else if (Std.is(symbol, LiteralSymbol))
			literals.remove(cast(symbol, LiteralSymbol));

		return symbol;
	}

	/**
	 * 변수 심볼을 찾는다.
	 * 
	 * @param	id
	 * @return
	 */
	public function getVariable(id:String):VariableSymbol {
		for ( i in 0...variables.length) {
			if (variables[i].id == id)
				return variables[i];
		}		
		
		return null;
	}
	
	/**
	 * 함수 심볼을 찾는다.
	 * 
	 * @param	id
	 * @param	parameterType
	 * @return
	 */
	public function getFunction(id:String, parameterType:Array<String>):FunctionSymbol {
		for (i in 0...functions.length) {
			if (functions[i].id == id) {
				
				// 파라미터 옵션이 없으면 첫 번째 찾은 함수를 리턴한다.
				if(parameterType == null)
					return functions[i];
				
				if (functions[i].parameters.length != parameterType.length)	
					continue;
					
				var match:Bool = true;	
					
				for (j in 0...functions[i].parameters.length) {
					if (functions[i].parameters[j].type != parameterType[j] && functions[i].parameters[j].type != "*") {
						match = false;
						break;
					}
				}
				
				if (match)
					return functions[i];
			}
		}
		
		return null;
	}
	
	/**
	 * 클래스 심볼을 찾는다.
	 * 
	 * @param	id
	 * @return
	 */
	public function getClass(id:String):ClassSymbol {
		for ( i in 0...classes.length) {
			if (classes[i].id == id)
				return classes[i];
		}
		
		return null;
	}

	/**
	 * 리터럴 테이블에 넘겨진 값이 존재하는 경우 그 참조를 리턴하고, 없으면 새로 추가한 후 리턴한다.
	 * 
	 * @param value
	 * @param type
	 * @return
	 */
	public function getLiteral(value:String, type:String):LiteralSymbol {
		
		for (i in 0...literals.length) {
			if (literals[i].type == type && literals[i].value == value)
				return literals[i];
		}

		var literal:LiteralSymbol = new LiteralSymbol(value, type);
		add(literal);
		
		return literal;
	}
	
}