package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 이항 연산자 구문 패턴
 * 
 * 형식: A (OP) B
 * 
 * @author 김 현준
 */
class InfixSyntax implements Syntax {

	public var left:Array<Token>;
	public var right:Array<Token>;
	public var operator:Token;
	
	public function new(operator:Token, left:Array<Token>, right:Array<Token>) {
		this.left = left;
		this.right = right;
		this.operator = operator;
	}		
	
	/**
	 * 토큰열이 이항 연산자 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);
		
		if (indexOfLPO < 0)
			return false;

		if (!tokens[indexOfLPO].isPrefix() && !tokens[indexOfLPO].isSuffix())
			return true;
			
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 이항 연산자 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):InfixSyntax {
		
		var LPOIndex:Int = TokenTools.indexOfLPO(tokens);

		var depth:Int = 0;
		for (i in 0...tokens.length) { 
			if (tokens[i].type == Type.SHELL_OPEN)
				depth++;
			else if (tokens[i].type == Type.SHELL_CLOSE)
				depth--;
		}

		// 껍데기가 온전히 닫혀 있는지 검사한다.
		if (depth > 0) {
			
			Debug.report("Syntax error", "insert \")\" to complete Expression", lineNumber);			
			return null;
		}

		if (depth < 0) {
			Debug.report("Syntax error", "delete \"(\"", lineNumber);	
			return null;
		}

		// 연산자 취득
		var operator:Token = tokens[LPOIndex];

		// 좌항과 우항
		var left:Array<Token> = tokens.slice(0, LPOIndex);
		var right:Array<Token> = tokens.slice(LPOIndex + 1, tokens.length);

		return new InfixSyntax(operator, left, right);
	}
}