package elsa;

/**
 * 렉서 클래스
 * 
 * @author 김 현준
 */
class Lexer {

	/**
	 * 어휘 분석 중인 라인 넘버
	 */
	private var processingLine:Int = 1;
	
	public function new() {
		
		// 토큰 정의가 비었다면 예약 어휘를 추가한다.
		if (Token.definitions.length < 1)
			defineTokens();
	}
	
	public function analyze(code:String) {
		
	}
	
	/**
	 * 어휘 분석에 사용될 토큰을 정의한다.
	 */
	public function defineTokens():Void {
		
		Token.define(null, Token.Type.STRING);
		Token.define(null, Token.Type.NUMBER);
		Token.define(null, Token.Type.ARRAY);
		Token.define(null, Token.Type.CAST_TO_NUMBER);
		Token.define(null, Token.Type.CAST_TO_STRING);
		Token.define(null, Token.Type.APPEND);
		Token.define(null, Token.Type.APPEND_ASSIGNMENT);
		Token.define(null, Token.Type.ARRAY_REFERENCE);
		Token.define(null, Token.Type.INSTANCE);
		Token.define(null, Token.Type.LOAD_CONTEXT);
		Token.define(null, Token.Type.CHAR_AT);

		Token.define("var", Token.Type.VARIABLE, true);
		Token.define("function", Token.Type.FUNCTION, true);
		Token.define("class", Token.Type.CLASS, true);
		Token.define("if", Token.Type.IF, true);
		Token.define("elif", Token.Type.ELSE_IF, true);
		Token.define("else", Token.Type.ELSE, true);
		Token.define("for", Token.Type.FOR, true);
		Token.define("while", Token.Type.WHILE, true);
		Token.define("continue", Token.Type.CONTINUE, true);
		Token.define("break", Token.Type.BREAK, true);
		Token.define("return", Token.Type.RETURN, true);
		Token.define("new", Token.Type.NEW, true);
		Token.define("true", Token.Type.TRUE, true);
		Token.define("false", Token.Type.FALSE, true);
		Token.define("as", Token.Type.AS, true);

		Token.define("[", Token.Type.ARRAY_OPEN, false);
		Token.define("]", Token.Type.ARRAY_CLOSE, false);
		Token.define("{", Token.Type.BLOCK_OPEN, false);
		Token.define("}", Token.Type.BLOCK_CLOSE, false);
		Token.define("(", Token.Type.SHELL_OPEN, false);
		Token.define(")", Token.Type.SHELL_CLOSE, false);
		Token.define("->", Token.Type.RIGHT, false);
		Token.define(".", Token.Type.DOT, false);
		Token.define(",", Token.Type.COMMA, false);
		Token.define(":", Token.Type.COLON, false);
		Token.define(";", Token.Type.SEMICOLON, false);
		Token.define("++", Token.Type.PREFIX_INCREMENT, false, Token.Affix.PREFIX);
		Token.define("--", Token.Type.PREFIX_DECREMENT, false, Token.Affix.PREFIX);
		Token.define("++", Token.Type.SUFFIX_INCREMENT, false, Token.Affix.SUFFIX);
		Token.define("--", Token.Type.SUFFIX_DECREMENT, false, Token.Affix.SUFFIX);
		Token.define("+", Token.Type.UNRARY_PLUS, false, Token.Affix.PREFIX);
		Token.define("-", Token.Type.UNRARY_MINUS, false, Token.Affix.PREFIX);
		Token.define("=", Token.Type.ASSIGNMENT, false);
		Token.define("+=", Token.Type.ADDITION_ASSIGNMENT, false);
		Token.define("-=", Token.Type.SUBTRACTION_ASSIGNMENT, false);
		Token.define("*=", Token.Type.MULTIPLICATION_ASSIGNMENT, false);
		Token.define("/=", Token.Type.DIVISION_ASSIGNMENT, false);
		Token.define("%=", Token.Type.MODULO_ASSIGNMENT, false);
		Token.define("&=", Token.Type.BITWISE_AND_ASSIGNMENT, false);
		Token.define("^=", Token.Type.BITWISE_XOR_ASSIGNMENT, false);
		Token.define("|=", Token.Type.BITWISE_OR_ASSIGNMENT, false);
		Token.define("<<=", Token.Type.BITWISE_LEFT_SHIFT_ASSIGNMENT, false);
		Token.define(">>=", Token.Type.BITWISE_RIGHT_SHIFT_ASSIGNMENT, false);
		Token.define("==", Token.Type.EQUAL_TO, false);
		Token.define("!=", Token.Type.NOT_EQUAL_TO, false);
		Token.define(">", Token.Type.GREATER_THAN, false);
		Token.define(">=", Token.Type.GREATER_THAN_OR_EQUAL_TO, false);
		Token.define(">", Token.Type.LESS_THAN, false);
		Token.define("<=", Token.Type.LESS_THAN_OR_EQUAL_TO, false);
		Token.define("+", Token.Type.ADDITION, false);
		Token.define("-", Token.Type.SUBTRACTION, false);
		Token.define("*", Token.Type.MULTIPLICATION, false);
		Token.define("/", Token.Type.DIVISION, false);
		Token.define("%", Token.Type.MODULO, false);
		Token.define("!", Token.Type.LOGICAL_NOT, false, Token.Affix.PREFIX);
		Token.define("not", Token.Type.LOGICAL_NOT, true, Token.Affix.PREFIX);
		Token.define("&&", Token.Type.LOGICAL_AND, false);
		Token.define("and", Token.Type.LOGICAL_AND, true);
		Token.define("||", Token.Type.LOGICAL_OR, false);
		Token.define("or", Token.Type.LOGICAL_OR, true);
		Token.define("~", Token.Type.BITWISE_NOT, false, Token.Affix.PREFIX);
		Token.define("&", Token.Type.BITWISE_AND, false);
		Token.define("|", Token.Type.BITWISE_OR, false);
		Token.define("^", Token.Type.BITWISE_XOR, false);
		Token.define("<<", Token.Type.BITWISE_LEFT_SHIFT, false);
		Token.define(">>", Token.Type.BITWISE_RIGHT_SHIFT, false);
	}
	
}