package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 함수 호출 구문 패턴
 * 
 * 형식: F(X, Y, Z, ..., ?)
 * 
 * @author 김 현준
 */
class FunctionCallSyntax implements Syntax {

	public var functionName:Token;
	public var functionArguments:Array<Array<Token>>;
	
	public function new(functionName:Token, functionArguments:Array<Array<Token>> = null) {
		this.functionName = functionName;
		this.functionArguments = functionArguments;
	}	
	
	/**
	 * 토큰열이 함수 호출 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length >= 3)
		
			// 토큰열의 머리 부분을 체크한다.
			if (tokens[0].type == Type.ID)
			
				// 괄호 조건을 만족하는지 체크한다.
				if (tokens[1].type == Type.ShellOpen)
					if (TokenTools.indexOfShellClose(tokens, 2) == tokens.length - 1)
						return true;

		return false;
	}
	
	/**
	 * 토큰열을 분석하여 함수 호출 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):FunctionCallSyntax {		
		
		// match가 이미 한 번 실행되었다는 전제 하에서 처리한다.
		var functionArguments:Array<Array<Token>> = TokenTools.getArguments(tokens.slice(2, tokens.length - 1));	
		
		if (functionArguments.length == 1 && functionArguments[0].length == 0) 
			return new FunctionCallSyntax(tokens[0], new Array<Array<Token>>());
		else 
			return new FunctionCallSyntax(tokens[0], functionArguments);
	}
}