package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * Else 문 구문 패턴
 * 
 * 형식: else
 * 
 * @author 김 현준
 */
class ElseSyntax implements Syntax {

	public function new() {
		
	}	
	
	/**
	 * 토큰열이 ... 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Token.Type.ELSE)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 ... 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ElseSyntax {
		return new ElseSyntax();
	}
}