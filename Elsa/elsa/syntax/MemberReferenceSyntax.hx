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
	
	public var instance:Array<Token>;
	public var referneces:Array<Token>;
	
	public function new(instance:Array<Token>, referneces:Array<Token>) {
		this.instance = instance;
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
		
		var chunks:Array<Array<Token>> = TokenTools.split(tokens, Type.Dot, true);
		
		var instance:Array<Token> = chunks[0];
		var memberReferences:Array<Token> = new Array<Token>();
		
		if (instance.length < 1) {
			Debug.report("Syntax error", "참조 대상이 올바르지 않습니다.", lineNumber);
				return null;
		}
		
		for ( i in 1...chunks.length) {
			
			if (chunks[i].length > 1 || chunks[i].length < 1) {
				Debug.report("Syntax error", "참조 변수가 올바르지 않습니다.", lineNumber);
				return null;
			}			
			memberReferences.push(chunks[i][0]);
		}
		
		return new MemberReferenceSyntax(instance, memberReferences);
	}
}