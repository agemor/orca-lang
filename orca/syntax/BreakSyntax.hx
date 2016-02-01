package orca.syntax;

import orca.Token;

/**
 * Break 구문 패턴
 * 
 * 형식: break
 * 
 * @author 김 현준
 */
class BreakSyntax implements Syntax {

	public function new() {	}	
	
	/**
	 * 토큰열이 Break 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.Break)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 Break 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):BreakSyntax {
		return new BreakSyntax();
	}
}