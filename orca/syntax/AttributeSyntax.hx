package orca.syntax;

import orca.Token;
import orca.TokenTools;
import orca.debug.Debug;

/**
 * 속성 선택문 구문 패턴
 * 
 * 형식: else
 * 
 * @author 김 현준
 */
class AttributeSyntax implements Syntax {
	
	public var attributes:Array<Array<Token>>;
	
	public function new(attributes:Array<Array<Token>>) {
		this.attributes = attributes;
	}	
	
	/**
	 * 토큰열이 속성 선택문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		var indexOfLpo:Int = TokenTools.indexOfLpo(tokens);
		
		if (indexOfLpo < 0)
			return false;
		
		// 도트가 가장 최하위 연산자이면, 즉 도트를 제외하고 다른 연산자가 없을 때
		if (tokens[indexOfLpo].type == Type.Dot)
			return true;
		
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 속성 선택문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):AttributeSyntax {
		
		var attributes:Array<Array<Token>> = TokenTools.split(tokens, Type.Dot, true);
		
		for ( i in 0...attributes.length) {
			if (attributes[i].length < 1) {
				Debug.reportError("Syntax error 333", "속성이 비었습니다.", lineNumber);		
				return null;
			}
		}
		
		return new AttributeSyntax(attributes);
	}
}