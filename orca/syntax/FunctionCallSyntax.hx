package orca.syntax;

import orca.Token;
import orca.TokenTools;
import orca.debug.Debug;

/**
 * 함수 호출 구문 패턴
 * 
 * 형식: name(parameters);
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
		
		var indexOfLpo:Int = TokenTools.indexOfLpo(tokens);
		
		// 어떠한 유효 연산자라도 있을 경우 함수 호출이 아님
		if (indexOfLpo >= 0)
			return false;
			
		// 최소 길이 조건 확인
		if (tokens.length < 3) 	
			return false;
			
		// 첫 토큰이 ID이고 두 번째 토큰이 ShellOpen이면 조건 만족	
		if (tokens[0].type != Type.ID || tokens[1].type != Type.ShellOpen)
			return false;
			
		return true;
	}
	
	/**
	 * 토큰열을 분석하여 함수 호출 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):FunctionCallSyntax {		
		
		// 함수가 완전히 닫혔는지 확인
		if (TokenTools.indexOfShellClose(tokens, 2) != tokens.length - 1) {
			Debug.reportError("Syntax error", "함수가 종결되지 않았습니다.", lineNumber);
			return null;	
		}
		
		// 함수 매개 변수를 가져온다.
		var arguments:Array<Array<Token>> = TokenTools.split(tokens.slice(2, tokens.length - 1), Type.Comma, true);
		var trimmedArguments:Array<Array<Token>> = new Array<Array<Token>>();
		
		for (i in 0...arguments.length) {
			if (arguments[i].length > 0 ) trimmedArguments.push(arguments[i]);
		}
		
		
		return new FunctionCallSyntax(tokens[0], trimmedArguments);
	}
}