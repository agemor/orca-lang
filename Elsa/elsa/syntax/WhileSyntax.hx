package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * While 문 구문 패턴
 * 
 * 형식: while( C )
 * 
 * @author 김 현준
 */
class WhileSyntax implements Syntax {

	public var condition:Array<Token>;
	
	public function new(condition:Array<Token>) {
		this.condition = condition;
	}	
	
	/**
	 * 토큰열이 While 문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.IF)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 While 문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):WhileSyntax {
				
		if (tokens.length < 4) {
			Debug.report("Syntax error", "While statement is too short", lineNumber);
			return null;
		}

		// 괄호로 시작하는지 확인한다
		if (tokens[1].type != Type.SHELL_OPEN) {
			Debug.report("Syntax error", "While condition must start with \"(\"", lineNumber);
			return null;
		}

		// 괄호로 끝나는지 확인한다.
		if (tokens[tokens.length - 1].type != Type.SHELL_CLOSE) {
			Debug.report("Syntax error", "insert \")\" to complete Expression", lineNumber);	
			return null;
		}

		return new WhileSyntax(tokens.slice(1, tokens.length - 1));
	}
}