package orca;
import orca.symbol.SymbolTable;
import orca.Token.Type;
import orca.symbol.Symbol;
import orca.symbol.VariableSymbol;
import orca.symbol.FunctionSymbol;
import orca.symbol.ClassSymbol;
import orca.symbol.LiteralSymbol;

/**
 * Orca Assembly Parser
 * 
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
		case Type.Addition:  return 1;
		case Type.Subtraction: return 2;
		case Type.Division: return 3;
		case Type.Multiplication: return 4;
		case Type.Modulo: return 5;
		case Type.BitwiseAnd: return 6;
		case Type.BitwiseOr: return 7;
		case Type.BitwiseXor: return 8;
		case Type.BitwiseNot: return 9;
		case Type.UnraryMinus: return 10;
		case Type.BitwiseLeftShift: return 11;
		case Type.BitwiseRightShift: return 12;
		case Type.Append: return 13;
		case Type.Assignment: return 14;
		case Type.AdditionAssignment, Type.PrefixIncrement, Type.SuffixIncrement: return 15;
		case Type.SubtractionAssignment, Type.PrefixDecrement, Type.SuffixDecrement: return 16;
		case Type.DivisionAssignment: return 17;
		case Type.MultiplicationAssignment: return 18;
		case Type.ModuloAssignment: return 19;
		case Type.BitwiseAndAssignment: return 20;
		case Type.BitwiseOrAssignment: return 21;
		case Type.BitwiseXorAssignment: return 22;
		case Type.BitwiseLeftShiftAssignment: return 23;	
		case Type.BitwiseRightShiftAssignment: return 24;
		case Type.AppendAssignment:	return 25;		
		case Type.EqualTo: return 38;
		case Type.NotEqualTo: return 39;
		case Type.GreaterThan: return 40;
		case Type.GreaterThanOrEqualTo: return 41;
		case Type.LessThan: return 42;
		case Type.LessThanOrEqualTo: return 43;
		case Type.LogicalAnd: return 44;
		case Type.LogicalOr: return 45;
		case Type.LogicalNot: return 46;
		case Type.CastToNumber: return 47;
		case Type.CastToString:	return 48;	
		case Type.CharAt: return 49;
		case Type.RuntimeValueAccess: return 50;
		default: return 0;
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
			case Type.CastToNumber, Type.CastToString, Type.LogicalNot,
				 Type.BitwiseNot, Type.UnraryMinus:
					 
				writeCode("OPR " + getOperatorNumber(token.type));
				
			// 값을 증감시킨 다음 푸쉬한다.
			case Type.PrefixDecrement, Type.PrefixIncrement:
				
				writeCode("PSH 1");
				writeCode("OPR " + (getOperatorNumber(token.type) + (token.useAsArrayReference ? 12 : 0)));
				
				if (token.doNotPush)
					writeCode("POP 0");
				
			// 값을 증감시킨 후 예전 값을 반환한다.
			case Type.SuffixDecrement, Type.SuffixIncrement:
				
				writeCode("PSH 1");
				writeCode("OPR " + (getOperatorNumber(token.type) + (token.useAsArrayReference ? 12 : 0)));				
				writeCode("PSH " + (token.type == Type.SuffixIncrement ? "-1" : "1"));
				writeCode("OPR " + getOperatorNumber(Type.Addition));
				
				if (token.doNotPush)
					writeCode("POP 0");
				
			// 이항 연산자
			case Type.Addition, Type.Subtraction, Type.Division,
				 Type.Multiplication, Type.Modulo, Type.BitwiseAnd,
				 Type.BitwiseOr, Type.BitwiseXor, Type.BitwiseLeftShift,
				 Type.BitwiseRightShift, Type.LogicalAnd, Type.LogicalOr,
				 Type.Append, Type.EqualTo, Type.NotEqualTo,
				 Type.GreaterThan, Type.GreaterThanOrEqualTo, Type.LessThan,
				 Type.LessThanOrEqualTo, Type.RuntimeValueAccess, Type.CharAt:						 
				
				writeCode("OPR " + getOperatorNumber(token.type));
			
			// 이항 연산 후 대입 연산자
			case Type.Assignment, Type.AdditionAssignment, Type.SubtractionAssignment, Type.DivisionAssignment,
				 Type.MultiplicationAssignment, Type.ModuloAssignment, Type.BitwiseAndAssignment,
				 Type.BitwiseOrAssignment, Type.BitwiseXorAssignment, Type.BitwiseLeftShiftAssignment,
				 Type.BitwiseRightShiftAssignment, Type.AppendAssignment:
					 
				writeCode("OPR " + (getOperatorNumber(token.type) + (token.useAsArrayReference ? 12 : 0)));

			// 배열 참조 연산자
			case Type.ArrayReference:

				// 배열의 차원수를 취득한다.
				var dimensions:Int = Std.parseInt(token.value);
				
				/* a[A][B] =
				 * 
				 * PUSH B
				 * PUSH A
				 * PUSH a
				 * POP 0 // a
				 * POP 1 // B
				 * POP 2 // A
				 * ESI 0, 0, 2
				 * ESI 0, 0, 1
				 */
				var j:Int = dimensions + 1;
				
				if (token.useAsAddress) 
					j --;				
				
				while (-- j > 0)
					writeCode("RDA");
				
			// 함수 호출 / 어드레스 등의 역할
			case Type.ID:

				var symbol:Symbol = token.getTag();

				// 변수일 경우				
				if (Std.is(symbol, VariableSymbol)) {
					
					if (token.useAsAddress)
						writeCode("PSH " + symbol.address);
					else
						writeCode("PSM " + symbol.address);					
				}

				// 함수일 경우
				else if (Std.is(symbol, FunctionSymbol)) {
					
					var functn:FunctionSymbol = cast(symbol, FunctionSymbol);

					// 네이티브 함수일 경우
					if (functn.isNative) {

						// 그냥 네이티브 어셈블리를 쓴다.
						writeCode(functn.nativeFunction.assembly);

					} else {

						/*
						 * 프로시져 호출의 토큰 구조는
						 * 
						 * ARGn, ARGn-1, ... ARG1, PROC_ID 로 되어 있다.
						 */
						
						// 스코프 시작
						writeCode("OSC");
						 
						// 인수를 뽑아 낸 후, 프로시져의 파라미터에 대응시킨다.						
						for ( j in 0...functn.parameters.length) {
							writeCode("SAL " + functn.parameters[functn.parameters.length - 1 - j].address);
							writeCode("PSH " + functn.parameters[functn.parameters.length - 1 - j].address);
							writeCode("STO");
						}

						// 현재 위치를 스택에 넣는다.
						writeCode("PSC");

						// 함수 시작부로 점프한다.
						writeCode("PSH %" + functn.functionEntry);
						writeCode("JMP");
						
						// 스코프 끝
						writeCode("CSC");
						
					}
				}

			case Type.True, Type.False, Type.String, Type.Number:
				
				if (!token.tagged) {					
					writeCode("PSH " + token.value);
				} else {
					// 리터럴 심볼을 취득한다.
					var literal:LiteralSymbol = cast(token.getTag(), LiteralSymbol);

					// 리터럴의 값을 추가한다.
					writeCode("PSM " + literal.address);
				}				
			case Type.Array:

				// 현재 토큰의 값이 인수의 갯수가 된다.
				var numberOfArguments:Int = Std.parseInt(token.value);
				
				// 동적 배열을 할당한다.
				writeCode("DAA");
				writeCode("POP 0");
				
				// 배열에 집어넣기 작업
				for ( j in 0...numberOfArguments) {
					if (j % 2 == 0) continue;
					writeCode("PSR 0");
					writeCode("STA");
				}					
				writeCode("PSR 0");
				
			case Type.Instance:

				// 앞 토큰은 인스턴스의 클래스이다.
				var targetClass:ClassSymbol = cast(tokens[i - 1].getTag(), ClassSymbol);
				
				// 인스턴스를 동적 할당한다.
				writeCode("DAA");
				writeCode("POP 0");
				
				// 오브젝트의 맴버 변수에 해당하는 데이터를 동적 할당한다.
				var assignedIndex:Int = 0;
				for ( j in 0...targetClass.members.length) {

					if (Std.is(targetClass.members[j], FunctionSymbol))
						continue;

					var member:VariableSymbol = cast(targetClass.members[j], VariableSymbol);
					
					// 초기값을 할당한다.					
					writeCode("PSM " + member.address);
					
					// 인스턴스에 맴버를 추가한다.
					writeCode("PSH " + assignedIndex);
					writeCode("PSR 0");
					writeCode("STA");
					assignedIndex++;
				}

				// 배열을 리턴한다.
				writeCode("PSR 0");
				
				default:
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