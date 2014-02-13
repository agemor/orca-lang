package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;

/**
 * 배열 구문 패턴
 * 
 * 형식: [A, B, C, D, ... , Z]
 * 
 * @author 김 현준
 */
class ArraySyntax implements Syntax {

	public var elements:Array<Array<Token>>;

	public function new(elements:Array<Array<Token>>) {
		this.elements = elements;
	}
	
	/**
	 * 토큰열이 배열 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens[0].type == Type.ARRAY_OPEN) 
			if (TokenTools.indexOfArrayClose(tokens) == tokens.length - 1)
				return true;		
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 배열 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ArraySyntax {
		
		var elements:Array<Array<Token>> = TokenTools.getArguments(tokens.slice(1, tokens.length - 1));		
		var syntax:ArraySyntax = new ArraySyntax(elements);

		return syntax;
	}
}