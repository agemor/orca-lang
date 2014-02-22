package elsa;
import elsa.Token.Affix;
import elsa.symbol.Symbol;

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
	private var tag:Symbol;
	public var tagged:Bool = false;
	
	/**
	 * 어휘 분석 시 단어별로 처리할 것인지의 여부
	 */
	public var wholeWord:Bool = false;
	public var useAsAddress:Bool = false;
	public var useAsArrayReference:Bool = false;
	public var doNotPush:Bool = false;
	
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
	 * 토큰의 태그를 취득한다.
	 * 
	 * @return
	 */
	public function getTag():Symbol {
		return tag;
	}
	
	/**
	 * 토큰에 태그를 설정한다.
	 * 
	 * @param	tag
	 * @return
	 */
	public function setTag(tag:Symbol):Void {
		this.tag = tag;
		tagged = true;
	}
	
	/**
	 * 토큰에서 태그를 제거한다.
	 */
	public function removeTag():Void {
		this.tag = null;
		this.tagged = false;
	}
	
	public function copy():Token {
		var token:Token = new Token(type, value);
		token.affix = affix;
		token.tag = tag;
		token.tagged = tagged;
		token.wholeWord = wholeWord;
		token.useAsAddress = useAsAddress;
		token.useAsArrayReference = useAsArrayReference;
		token.doNotPush = doNotPush;
		
		return token;
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
		case Type.Dot:
			return 1;
		case Type.ArrayOpen:
			return 2;
		case Type.As: 
			return 3;
		case Type.SuffixIncrement, Type.SuffixDecrement:
			return 4;
		case Type.PrefixIncrement, Type.PrefixDecrement, Type.UnraryMinus,
			 Type.UnraryPlus, Type.LogicalNot, Type.BitwiseNot:
			return 5;
		case Type.Multiplication, Type.Division, Type.Modulo:
			return 6;
		case Type.Addition, Type.Subtraction:
			return 7;
		case Type.BitwiseLeftShift, Type.BitwiseRightShift:
			return 8;
		case Type.LessThan, Type.LessThanOrEqualTo, Type.GreaterThan, Type.GreaterThanOrEqualTo:
			return 9;
		case Type.EqualTo, Type.NotEqualTo:
			return 10;
		case Type.BitwiseAnd:
			return 11;
		case Type.BitwiseXor:
			return 12;
		case Type.BitwiseOr:
			return 13;
		case Type.LogicalAnd:
			return 14;
		case Type.LogicalOr, Type.RuntimeValueAccess:
			return 15;
		case Type.Assignment, Type.AdditionAssignment, Type.SubtractionAssignment,
			 Type.MultiplicationAssignment, Type.DivisionAssignment, Type.ModuloAssignment,
			 Type.BitwiseAndAssignment, Type.BitwiseXorAssignment, Type.BitwiseOrAssignment,
			 Type.BitwiseLeftShiftAssignment, Type.BitwiseRightShiftAssignment, Type.AppendAssignment:
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
				return definitions[i].copy();
		}
		return null;
	}
	
	public static function findByValue(value:String, wholeWord:Bool):Token {
		
		value = StringTools.trim(value);
		
		// 빈 값이면 아무것도 출력하지 않는다.
		if (value.length == 0)
			return null;
		
		// 단어 단위 검색일 경우, 심볼 전체가 매치될 경우에만 해당
		if (wholeWord) {
			for (i in 0...definitions.length) {
				if (definitions[i].wholeWord && definitions[i].value == value)
					return definitions[i];
			}
			return new Token(Type.ID, value);
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
					maxMatched = j;
					candidate = definitions[i];
				}
			}
			if (candidate == null) return null;
			else return candidate.copy();
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
	
	Define; Right;
	
	Include;
	
	ID; Variable; New; ArrayReference;
	
	If; Else; For; While;
	Continue; Break; Return; RuntimeValueAccess;
	
	True; False; String; Number; Array;
	
	ArrayOpen; ArrayClose;
	BlockOpen; BlockClose;
	ShellOpen; ShellClose;
	
	Dot; Comma; Colon; Semicolon; From; In;
	
	PrefixIncrement; PrefixDecrement; SuffixIncrement; SuffixDecrement;
	UnraryPlus; UnraryMinus;	
	
	Addition; Append; Subtraction; Multiplication; Division; Modulo;
	Assignment; AdditionAssignment; AppendAssignment; SubtractionAssignment; MultiplicationAssignment; DivisionAssignment; ModuloAssignment;
	
	BitwiseNot; BitwiseAnd; BitwiseOr; BitwiseXor; BitwiseLeftShift; BitwiseRightShift;
	BitwiseAndAssignment; BitwiseXorAssignment; BitwiseOrAssignment; BitwiseLeftShiftAssignment; BitwiseRightShiftAssignment;
	
	EqualTo; NotEqualTo; GreaterThan; GreaterThanOrEqualTo; LessThan; LessThanOrEqualTo;
	LogicalNot; LogicalAnd; LogicalOr;
	
	CastToNumber; CastToString;
	
	Instance; CharAt; PushParameters;
	As;
	
}