package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 캐스팅 구문 패턴
 * 
 * 형식 A as B
 * 
 * @author 김 현준
 */
class CastingSyntax implements Syntax {

	// 캐스팅 될 대상
	public var target:Array<Token>;

	// 캐스팅 종류
	public var castingType:String;
	
	public function new(target:Array<Token>, castingType:String) {
		this.target = target;
		this.castingType = castingType;
	}	
	
	/**
	 * 토큰열이 캐스팅 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);
		
		if (indexOfLPO < 0)
			return false;

		if (tokens[indexOfLPO].type != Type.As)
			return false;
			
		return true;
	}
	
	/**
	 * 토큰열을 분석하여 캐스팅 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):CastingSyntax {
		
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);

		// 캐스팅 대상이 없다면
		if (tokens.length <= indexOfLPO + 1) {
			Debug.reportError("Syntax error", "Cannot find casting target.", lineNumber);		
			return null;
		}

		var target:Array<Token> = tokens.slice(0, indexOfLPO);
		var castingType:String = tokens[indexOfLPO + 1].value;

		return new CastingSyntax(target, castingType);
	}
}