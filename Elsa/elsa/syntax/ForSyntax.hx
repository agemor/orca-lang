package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * For 문 구문 패턴
 * 
 * 형식: for ( i in 0 ... 100 )
 * 
 * @author 김 현준
 */
class ForSyntax implements Syntax {

	public var counter:Token;

	public var start:Array<Token>;
	public var end:Array<Token>;
	
	public function new(counter:Token, start:Array<Token>, end:Array<Token>) {
		
		this.counter = counter;

		this.start = start;
		this.end = end;
	}	
	
	/**
	 * 토큰열이 For 문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.For)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 For 문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ForSyntax {
		
		if (tokens.length < 7) {
			Debug.reportError("Syntax error", "For syntax is not valid", lineNumber);		
			return null;
		}

		// 괄호로 시작하는지 확인한다
		if (tokens[1].type != Type.ShellOpen) {
			Debug.reportError("Syntax error", "For condition must start with \"(\"", lineNumber);		
			return null;
		}

		// 괄호로 끝나는지 확인한다.
		if (tokens[tokens.length - 1].type != Type.ShellClose) {
			Debug.reportError("Syntax error", "insert \")\" to complete Expression", lineNumber);
			return null;
		}

		if (tokens[2].type != Type.ID) {
			Debug.reportError("Syntax error", "Counter variable is not valid", lineNumber);		
			return null;
		}
		
		if (tokens[3].type != Type.In) {
			Debug.reportError("Syntax error", "Could not find token 'in'", lineNumber);
			return null;
		}

		// 증감 범위를 자른다.
		var range:Array<Token> = tokens.slice(4, tokens.length - 1);

		// 범위지정 토큰의 위치를 찾는다.
		var indexOfRange:Int = TokenTools.indexOf(range, Type.From);

		if (indexOfRange < 0) {
			Debug.reportError("Syntax error", "Could not find token '...'", lineNumber);
			return null;
		}

		// 범위지정 토큰을 기준으로 분할한다.
		var start:Array<Token> = range.slice(0, indexOfRange);
		var end:Array<Token> = range.slice(indexOfRange + 1, range.length);

		return new ForSyntax(tokens[2], start, end);
	}
}