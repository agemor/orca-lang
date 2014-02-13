package elsa.syntax;

import elsa.Token;
import elsa.Token.Type;

/**
 * Return 구문 패턴
 * 
 * 형식: return V
 * 
 * @author 김 현준
 */
class ReturnSyntax implements Syntax {

	public var returnValue:Array<Token>;
	
	public function new(returnValue:Array<Token>) {
		this.returnValue = returnValue;
	}	
	
	/**
	 * 토큰열이 Return 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.RETURN)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 Return 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ReturnSyntax {
		return new ReturnSyntax(tokens.slice(0));
	}
}