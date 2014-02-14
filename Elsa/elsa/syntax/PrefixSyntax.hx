package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 접두형 단항 연산 구문 패턴
 * 
 * 형식: A (OP)
 * 
 * @author 김 현준
 */
class PrefixSyntax implements Syntax {

	public var operand:Array<Token>;
	public var operator:Token;
	
	public function new(operator:Token, operand:Array<Token>) {
		this.operator = operator;
		this.operand = operand;
	}	
	
	/**
	 * 토큰열이 접두형 단항 연산 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);
		
		if (indexOfLPO < 0)
			return false;

		if (tokens[indexOfLPO].isPrefix())
			return true;
			
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 접두형 단항 연산 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):PrefixSyntax {
		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);

		var depth:Int = 0;
		for (i in 0...tokens.length) {
			if (tokens[i].type == Type.ShellOpen)
				depth++;
			else if (tokens[i].type == Type.ShellClose)
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

		return new PrefixSyntax(tokens[indexOfLPO], tokens.slice(indexOfLPO + 1, tokens.length));
	}
}