package elsa;
import elsa.Symbol.Class;
import elsa.Symbol.Function;
import elsa.Symbol.Literal;
import elsa.Symbol.Variable;

/**
 * ...
 * @author 김 현준
 */
class Assembly {

	/**
	 * 심볼 테이블
	 */
	public var symbolTable:SymbolTable;
	
	/**
	 * 어셈블리 코드
	 */
	public var code:String = "";
	private var frozenCode:String;
	
	public function freeze():Void {
		frozenCode = code;
		code = "";
	}
	
	public function melt():Void {
		code += frozenCode;
		frozenCode = "";
	}	
	
	public function new(symbolTable:SymbolTable) {
		this.symbolTable = symbolTable;
	}
	
	/**
	 * 연산자 번호를 구한다.
	 * 
	 * @param	type
	 * @return
	 */
	public static function getOperatorNumber(type:Token.Type):Int {
		switch (type) {
		case ADDITION:
			return 1;
		case SUBTRACTION:
			return 2;
		case DIVISION:
			return 3;
		case MULTIPLICATION:
			return 4;
		case MODULO:
			return 5;
		case BITWISE_AND:
			return 6;
		case BITWISE_OR:
			return 7;
		case BITWISE_XOR:
			return 8;
		case BITWISE_NOT:
			return 9;
		case BITWISE_LEFT_SHIFT:
			return 10;
		case BITWISE_RIGHT_SHIFT:
			return 11;
		case EQUAL_TO:
			return 12;
		case NOT_EQUAL_TO:
			return 13;
		case GREATER_THAN:
			return 14;
		case GREATER_THAN_OR_EQUAL_TO:
			return 15;
		case LESS_THAN:
			return 16;
		case LESS_THAN_OR_EQUAL_TO:
			return 17;
		case LOGICAL_AND:
			return 18;
		case LOGICAL_OR:
			return 19;
		case LOGICAL_NOT:
			return 20;
		case APPEND:
			return 21;
		case CAST_TO_NUMBER:
			return 22;
		case CAST_TO_STRING:
			return 23;
		case CHAR_AT:
			return 24;
		case UNRARY_MINUS:
			return 25;
		default:
			return 0;
		}
	}
	
	/**
	 * 토큰열로 구성된 스택 어셈블리를 직렬화한다.
	 * 
	 * @param tokens
	 */
	public function writeLine(tokens:Array<Token>):Void {
		for ( i in 0...tokens.length) { 
			var token:Token = tokens[i];

			switch (token.type) {

			// 접두형 단항 연산자
			case CAST_TO_NUMBER, CAST_TO_STRING, LOGICAL_NOT,
				 BITWISE_NOT, UNRARY_MINUS:

				writeCode("POP 0");
				writeCode("OPR 1, " + getOperatorNumber(token.type) + ", &0");
				writeCode("PSH &1");
				
			// 값을 증감시킨 다음 푸쉬한다.
			case PREFIX_DECREMENT, PREFIX_INCREMENT:

				writeCode("POP 0");
				writeCode("OPR 1, " + (token.type == Token.Type.PREFIX_INCREMENT ? 1 : 2) + ", &0, @"
						+ symbolTable.getLiteral("1", Symbol.Literal.NUMBER).address);
				writeCode("NDW &0, &1");
				writeCode("PSH &0");
				
			// 값을 푸쉬한 다음 증감시킨다.
			case SUFFIX_DECREMENT, SUFFIX_INCREMENT:

				writeCode("POP 0");
				writeCode("PSH &0");
				writeCode("OPR 1, " + (token.type == Token.Type.PREFIX_INCREMENT ? 1 : 2) + ", &0, @"
						+ symbolTable.getLiteral("1", Symbol.Literal.NUMBER).address);
				writeCode("NDW &0, &1");

			// 이항 연산자
			case ADDITION, SUBTRACTION, DIVISION,
				 MULTIPLICATION, MODULO, BITWISE_AND,
				 BITWISE_OR, BITWISE_XOR, BITWISE_LEFT_SHIFT,
				 BITWISE_RIGHT_SHIFT, LOGICAL_AND, LOGICAL_OR,
				 APPEND, EQUAL_TO, NOT_EQUAL_TO,
				 GREATER_THAN, GREATER_THAN_OR_EQUAL_TO, LESS_THAN,
				 LESS_THAN_OR_EQUAL_TO, CHAR_AT:

				writeCode("POP 0");
				writeCode("POP 1");
				writeCode("OPR 2, " + getOperatorNumber(token.type) + ", &1, &0");
				writeCode("PSH &2");

			// 이항 연산 후 대입 연산자
			case ADDITION_ASSIGNMENT, SUBTRACTION_ASSIGNMENT, DIVISION_ASSIGNMENT,
				 MULTIPLICATION_ASSIGNMENT, MODULO_ASSIGNMENT, BITWISE_AND_ASSIGNMENT,
				 BITWISE_OR_ASSIGNMENT, BITWISE_XOR_ASSIGNMENT, BITWISE_LEFT_SHIFT_ASSIGNMENT,
				 BITWISE_RIGHT_SHIFT_ASSIGNMENT:

				writeCode("POP 0");
				writeCode("POP 1");
				writeCode("OPR 2, " + getOperatorNumber(token.type) + ", &1, &0");
				writeCode("NDW &1, &2");

			// NDW -> SDW
			case APPEND_ASSIGNMENT:

				writeCode("POP 0");
				writeCode("POP 1");
				writeCode("OPR 2, " + getOperatorNumber(token.type) + ", &1, &0");
				writeCode("SDW &1, &2");

			// 이항 대입 연산자
			case ASSIGNMENT:

				writeCode("POP 0");
				writeCode("POP 1");

				// NDW, SDW, RDW 처리.
				switch (token.value) {

				// 실수형
				case "number":

					writeCode("NDW &1 ,&0");

				// 문자형
				case "string":

					writeCode("SDW &1 ,&0");

				// 레퍼런스형
				case "reference":

					writeCode("RDW &1 ,&0");
				}

			// 배열 참조 연산자
			case ARRAY_REFERENCE:

				// 배열의 차원수를 취득한다.
				var dimensions:Int = Std.parseInt(token.value);

				// 배열 어드레스를 pop한 후(0) 배열의 차원 수만큼 POP 한다.
				for(j in 0...(dimensions + 1))
					writeCode("POP " + j);

				/*
				 * a[A][B] =
				 * 
				 * PUSH A ~ PUSH B ~ PUSH a ~ POP 0 // a ~ POP 1 // B ~ POP 2 //
				 * A ~ ESI 0, 0, 2 ~ ESI 0, 0, 1
				 */
				var j:Int = dimensions + 1;
				while(--j > 0)
					writeCode("ESI 0, &0, &" + j);

				// 결과를 메인 스택에 집어넣는다.
				writeCode("PSH &0");

			// 함수 호출 / 어드레스 등의 역할
			case ID:

				var symbol:Symbol = token.getTag();

				// 변수일 경우				
				if (Std.is(symbol, Symbol.Variable)) {

					// 변수의 메모리 어드레스를 추가한다.
					writeCode("PSH @" + symbol.address);
				}

				// 함수일 경우
				else if (Std.is(symbol, Symbol.Function)) {
	
					var functn:Symbol.Function = cast(symbol, Symbol.Function);

					// 네이티브 함수일 경우
					if (functn.isNative) {

						// 그냥 네이티브 어셈블리를 쓴다.
						writeCode(functn.nativeFunction.assembly);

					} else {

						/*
						 * 프로시져 호출의 토큰 구조는
						 * 
						 * ARG1, ARG2, ... ARGn, PROC_ID 로 되어 있다.
						 */
						
						// 인수를 뽑아 낸 후, 프로시져의 파라미터에 대응시킨다.
						if (functn.parameters != null)
							for( j in 0...functn.parameters.length){

								// 인수 값을 뽑는다.
								writeCode("POP 0");

								// 파라미터 어드레스를 취득한다. 인수를 거꾸로 취득하고 있으므로, 매개변수도 거꾸로
								// 취득한다.
								var parameter:Symbol.Variable = functn.parameters[functn.parameters.length - 1 - j];

								// 인수가 실수형일 경우
								if (parameter.isNumber())
									writeCode("NDW " + parameter.address + ",  &0");

								else if (parameter.isString())
									writeCode("SDW " + parameter.address + ",  &0");

								else
									writeCode("RDW " + parameter.address + ",  &0");
							}

						// 현재 위치를 스택에 넣는다.
						writeCode("PSH $CURRENT_POINTER");

						// 함수 시작부로 점프한다.
						writeCode("JMP 0, %" + functn.functionEntry);
					}
				}

			case STRING, NUMBER:

				// 리터럴 심볼을 취득한다.
				var literal:Literal = cast(token.getTag(), Symbol.Literal);

				// 리터럴의 값을 추가한다.
				writeCode("PSH @" + literal.address);

			case LOAD_CONTEXT:

				// 클래스를 취득한다.
				var classs:Symbol.Class = cast(token.getTag(), Symbol.Class);

				// 인스턴스 주소를 뽑는다.
				writeCode("POP 0");

				// 오브젝트의 데이터와 리턴 결과 데이터를 일대일 대응시킨다.
				for ( j in 0...classs.members.length) { 

					if (Std.is(classs.members[j], Symbol.Function))
						continue;

					var member:Symbol.Variable = cast(classs.members[j], Symbol.Variable);

					// 리턴값의 인자번호를 뽑는다.
					writeCode("ESI 1, &0, " + j);

					// 공유 맴버의 레퍼런스를 업데이트한다.
					writeCode("RDW " + member.address + ", &1");
				}
				
			case ARRAY:

				// 현재 토큰의 값이 인수의 갯수가 된다.
				var numberOfArguments:Int = Std.parseInt(token.value);

				// 인수 갯수 만큼 뽑아 온다.
				for ( j in 0...numberOfArguments)
					// 인수 어드레스를 뽑는다.
					writeCode("POP " + (numberOfArguments - j));

				// 동적 배열을 할당한다.
				writeCode("DAA 0");

				// 배열에 집어넣기 작업
				for ( j in 0...numberOfArguments) 
					writeCode("EAD &0, &" + (j + 1));

				// 배열을 리턴한다.
				writeCode("PSH &0");

			case writeCodeTANCE:

				// 앞 토큰은 인스턴스의 클래스이다.
				var targetClass:Symbol.Class = cast(tokens[i - 1].getTag(), Symbol.Class);

				// 인스턴스를 동적 할당한다.
				writeCode("DAA 0");

				// 오브젝트의 맴버 변수에 해당하는 데이터를 동적 할당한다.
				for ( j in 0...targetClass.members.length) {

					if (Std.is(targetClass.members[j], Symbol.Function))
						continue;

					var member:Symbol.Variable = cast(targetClass.members[j], Symbol.Variable);

					// 초기값을 할당한다.
					if (member.type == "string") {
						writeCode("DSA &1");
						if (member.initialized)
							writeCode("SDW &1, " + member.address);
					} else if (member.type == "number") {
						writeCode("DNA &1");
						if (member.initialized)
							writeCode("NDW &1, " + member.address);
					} else {
						writeCode("DAA &1");
						if (member.initialized)
							writeCode("RDW &1, " + member.address);
					}

					// 인스턴스에 맴버를 추가한다.
					writeCode("EAD &0, &1");
				}

				// 배열을 리턴한다.
				writeCode("PSH &0");
			}
		}
	}

	/**
	 * 어셈블리 코드를 추가한다.
	 * 
	 * @param	code
	 */
	public function writeCode(code:String):Void {
		this.code += code + "\n";
	}

	
	/**
	 * 플래그를 심는다.
	 * 
	 * @param	number
	 */
	public function flag(number:Int):Void {
		writeCode("FLG %" + number);
	}
	
}