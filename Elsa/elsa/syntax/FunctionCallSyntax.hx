package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 함수 호출 구문 패턴
 * 
 * 형식: [Target ->] name(parameters);
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
		
		var lastIndexOfRight:Int = TokenTools.lastIndexOf(tokens, Type.Right);	
		
		// 전체 래핑인지 확인한다.
		if (tokens.length >= 3 && tokens[0].type == Type.ID && tokens[1].type == Type.ShellOpen) {
			if (TokenTools.indexOfShellClose(tokens, 2) == tokens.length - 1)
				return true;
		}
		
		// 기본적인 길이 제한을 만족하는지 확인
		if (tokens.length < lastIndexOfRight + 3) 	
			return false;
			
		// 패턴 매칭 확인	
		
		if (tokens[lastIndexOfRight + 1].type != Type.ID || tokens[lastIndexOfRight + 2].type != Type.ShellOpen)
			return false;
			
		// 마지막 닫기 문자 확인
		if (TokenTools.indexOfShellClose(tokens, lastIndexOfRight + 3) != tokens.length - 1)
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
		
		var lastIndexOfRight:Int = TokenTools.lastIndexOf(tokens, Type.Right);	
		var hasTarget:Bool = lastIndexOfRight > 0;		
		
		// 전체 래핑인지 확인한다.
		if (tokens[0].type == Type.ID && tokens[1].type == Type.ShellOpen) {
			if (TokenTools.indexOfShellClose(tokens, 2) == tokens.length - 1)
				hasTarget = false;
		}		
		
		var hasArguments:Bool = hasTarget ? tokens[lastIndexOfRight + 3].type != Type.ShellClose : tokens[2].type != Type.ShellClose;
		
		var functionName:Token = tokens[0];
		var functionArguments:Array<Array<Token>> = new Array<Array<Token>>();
		
		if (hasTarget) {
			functionArguments.push(tokens.slice(0, lastIndexOfRight));
			functionName = tokens[lastIndexOfRight + 1];
		}
		
		if (hasArguments) {
			
			var argumentStartIndex:Int = 2;
			if (hasTarget) argumentStartIndex += lastIndexOfRight + 1;
			
			var argumentEndIndex:Int = tokens.length - 1;
			
			// 매개 변수가 괄호로 싸여있지 않다면 에러.
			if (tokens[argumentStartIndex - 1].type != Type.ShellOpen || tokens[argumentEndIndex].type != Type.ShellClose) {
				Debug.reportError("Syntax error", "Parameter declaration must contained within the parantheses", lineNumber);
				return null;
			}	
			
			if (TokenTools.indexOfShellClose(tokens, argumentStartIndex) != argumentEndIndex) {
				Debug.reportError("Syntax error", "function shell close not match", lineNumber);
				return null;
			}
			
			functionName = tokens[argumentStartIndex - 2];
			functionArguments = functionArguments.concat(TokenTools.getArguments(tokens.slice(argumentStartIndex, argumentEndIndex)));
			
		}
		
		return new FunctionCallSyntax(functionName, functionArguments);
	}
}