package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 맴버 참조 구문 패턴
 * 
 * 형식: A.B.C ... .Z
 * 
 * @author 김 현준
 */
class MemberReferenceSyntax implements Syntax {

	public var referneces:Array<Array<Token>>;
	
	public function new(referneces:Array<Array<Token>>) {
		this.referneces = referneces;
	}	
	
	/**
	 * 토큰열이 맴버 참조 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {		
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);
		
		if (indexOfLPO < 0)
			return false;

		if (tokens[indexOfLPO].type == Type.Dot)
			return true;
			
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 맴버 참조 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):MemberReferenceSyntax {
		return new MemberReferenceSyntax(TokenTools.split(tokens, Type.Dot, true));
	}
}