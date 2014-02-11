package elsa;
import elsa.Token.Affix;

/**
 * 토큰 클래스
 * 
 * @author 김 현준
 */
class Token {

	/**
	 * 이 리스트에는 토큰의 정의가 저장되게 된다.
	 */
	public static var definitions:Array<Token> = new Array<Token>();
	
	/**
	 * 토큰 데이터
	 */
	public var type:Type;
	public var value:String;
	public var affix:Affix;
	
	/**
	 * 토큰 태그 정보
	 */
	public var tag:String;
	public var tagged:Bool = false;
	
	/**
	 * 어휘 분석 시 단어별로 처리할 것인지의 여부
	 */
	public var wholeWord = false;
	
	/**
	 * 토큰을 생성한다. 두 번째 인수를 넣을 경우 이 토큰은 데이터 토큰이 된다.
	 * @param	type
	 */
	public function new(type:Type, ?value:String) {
		this.type = type;
		this.value = value;
	}
	
	/**
	 * 토큰의 종류가 단항 접두사인지 확인한다.
	 * 
	 * @return
	 */
	public function isPrefix():Bool {
		if (affix == Affix.PREFIX)
			return true;
		return false;
	}
	
	/**
	 * 토큰의 종류가 단항 접미사인지 확인한다.
	 * 
	 * @return
	 */
	public function isSuffix():Bool {
		if (affix == Affix.SUFFIX)
			return true;
		return false;
	}
	
	/**
	 * 현재 토큰이 연산자일 경우, 연산자의 우선순위를 구한다.
	 * 
	 * ※ 연산자 우선순위는 C++의 것을 따른다.
	 * 
	 * @param token
	 * @return
	 */
	public function getPrecedence():Int {
		switch (type) {
		case DOT:
			return 1;
		case ARRAY_OPEN:
			return 2;
		case AS:
			return 3;
		case SUFFIX_INCREMENT, SUFFIX_DECREMENT:
			return 4;
		case PREFIX_INCREMENT, PREFIX_DECREMENT, UNRARY_PLUS,
			 UNRARY_MINUS, LOGICAL_NOT, BITWISE_NOT:
			return 5;
		case MULTIPLICATION, DIVISION, MODULO:
			return 6;
		case ADDITION, SUBTRACTION:
			return 7;
		case BITWISE_LEFT_SHIFT, BITWISE_RIGHT_SHIFT:
			return 8;
		case LESS_THAN, LESS_THAN_OR_EQUAL_TO, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO:
			return 9;
		case EQUAL_TO, NOT_EQUAL_TO:
			return 10;
		case BITWISE_AND:
			return 11;
		case BITWISE_XOR:
			return 12;
		case BITWISE_OR:
			return 13;
		case LOGICAL_AND:
			return 14;
		case LOGICAL_OR:
			return 15;
		case ASSIGNMENT, ADDITION_ASSIGNMENT, SUBTRACTION_ASSIGNMENT,
			 MULTIPLICATION_ASSIGNMENT, DIVISION_ASSIGNMENT, MODULO_ASSIGNMENT,
			 BITWISE_AND_ASSIGNMENT, BITWISE_XOR_ASSIGNMENT, BITWISE_OR_ASSIGNMENT,
			 BITWISE_LEFT_SHIFT_ASSIGNMENT, BITWISE_RIGHT_SHIFT_ASSIGNMENT:
			return 16;
		default:
			return 0;
		}
	}
	
	/**
	 * 어휘 분석 시 사용될 토큰 정의를 추가한다.
	 * 
	 * @param	type
	 * @param	value
	 * @param	wholeWord
	 * @param	affix
	 */
	public static function define(value:String, type:Type, wholeWord:Bool = false, affix:Affix = null):Token {
		var token:Token = new Token(type, value);
		token.wholeWord = wholeWord;
		token.affix = affix;
		
		definitions.push(token);
		
		return token;
	}
	
	/**
	 * 토큰 타입으로 토큰 정의를 가져온다.
	 * 
	 * @param	type
	 */
	public static function findByType(type:Type):Token {
		for (i in 0...definitions.length) {
			if (definitions[i].type == type)
				return definitions[i];
		}
		return null;
	}
	
	public static function findByValue(value:String, wholeWord:Bool):Token {
		
		// 빈 값이면 아무것도 출력하지 않는다.
		if (value.length == 0)
			return null;
		
		// 단어 단위 검색일 경우, 심볼 전체가 매치될 경우에만 해당
		if (wholeWord) {
			for (i in 0...definitions.length) {
				if (definitions[i].wholeWord && definitions[i].value == value)
					return definitions[i];
			}
			return null;
		}
		
		// 전 범위 검색일 경우
		else {
			var maxMatched:Int = 0;
			var candidate:Token = null;
			
			for (i in 0...definitions.length) {
				if (definitions[i].wholeWord || definitions[i].value == null)
					continue;
					
				// 정의 범위가 겹치는 것이 있을 수 있는데, 이 때는 더 많이 겹친 것을 선택한다.
				var j:Int = 0;
				while (definitions[i].value.length > j && value.length > j) {
					if (definitions[i].value.charAt(j++) != value.charAt(j - 1)) {
						j--;
						break;
					}					
				}
				if (definitions[i].value.length == j && j > maxMatched) {
					maxMatched = i;
					candidate = definitions[i];
				}
			}
			
			return candidate;
		}
		
	}
	
}

/**
* 토큰의 접사 종류
*/
enum Affix {
	PREFIX; SUFFIX; NONE;
}

/**
 * 토큰 종류
 */
enum Type {
	ID; VARIABLE; FUNCTION; CLASS; NEW; ARRAY_REFERENCE;
	
	IF; ELSE_IF; ELSE; FOR; WHILE;
	CONTINUE; BREAK; RETURN;
	
	TRUE; FALSE; STRING; NUMBER; ARRAY;
	
	ARRAY_OPEN; ARRAY_CLOSE;
	BLOCK_OPEN; BLOCK_CLOSE;
	SHELL_OPEN; SHELL_CLOSE;
	
	DOT; COMMA; COLON; SEMICOLON; RIGHT;
	
	PREFIX_INCREMENT; PREFIX_DECREMENT; SUFFIX_INCREMENT; SUFFIX_DECREMENT;
	UNRARY_PLUS; UNRARY_MINUS;	
	
	ADDITION; APPEND; SUBTRACTION; MULTIPLICATION; DIVISION; MODULO;
	ASSIGNMENT; ADDITION_ASSIGNMENT; APPEND_ASSIGNMENT; SUBTRACTION_ASSIGNMENT; MULTIPLICATION_ASSIGNMENT; DIVISION_ASSIGNMENT; MODULO_ASSIGNMENT;
	
	BITWISE_NOT; BITWISE_AND; BITWISE_OR; BITWISE_XOR; BITWISE_LEFT_SHIFT; BITWISE_RIGHT_SHIFT;
	BITWISE_AND_ASSIGNMENT; BITWISE_XOR_ASSIGNMENT; BITWISE_OR_ASSIGNMENT; BITWISE_LEFT_SHIFT_ASSIGNMENT; BITWISE_RIGHT_SHIFT_ASSIGNMENT;
	
	EQUAL_TO; NOT_EQUAL_TO; GREATER_THAN; GREATER_THAN_OR_EQUAL_TO; LESS_THAN; LESS_THAN_OR_EQUAL_TO;
	LOGICAL_NOT; LOGICAL_AND; LOGICAL_OR;
	
	CAST_TO_NUMBER; CAST_TO_STRING;
	
	INSTANCE; LOAD_CONTEXT;
	CHAR_AT; AS;
	
}