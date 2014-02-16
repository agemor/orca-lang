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
		
		if (!(tokens.length > 0 && tokens[0].type == Type.ID))
			return false;
		
		var case1:Bool = tokens.length >= 3 && tokens[1].type == Type.ShellOpen;
		var case2:Bool = tokens.length >= 5 && tokens[1].type == Type.Right;	
			
		if (TokenTools.indexOfShellClose(tokens, case2 ? 4: 2) != tokens.length - 1)
			return false;	
		
		if (case1 || case2)
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
		
		var hasTarget:Bool = (tokens[1].type == Type.Right);
		var hasArguments:Bool = hasTarget ? tokens[4].type != Type.ShellClose : tokens[2].type != Type.ShellClose;
		
		var functionName:Token = tokens[0];
		var functionArguments:Array<Array<Token>> = new Array<Array<Token>>();
		
		if (hasTarget) {
			functionArguments.push([tokens[0]]);
			functionName = tokens[2];
		}
		
		if (hasArguments) {
			
			var argumentStartIndex:Int = 2;
			if (hasTarget) argumentStartIndex += 2;
			
			var argumentEndIndex:Int = tokens.length - 1;
			
			// 매개 변수가 괄호로 싸여있지 않다면 에러.
			if (tokens[argumentStartIndex - 1].type != Type.ShellOpen || tokens[argumentEndIndex].type != Type.ShellClose) {
				Debug.report("Syntax error", "Parameter declaration must contained within the parantheses", lineNumber);
				return null;
			}	
			
			if (TokenTools.indexOfShellClose(tokens, argumentStartIndex) != argumentEndIndex) {
				Debug.report("Syntax error", "function shell close not match", lineNumber);
				return null;
			}
			
			functionName = tokens[argumentStartIndex - 2];
			functionArguments = functionArguments.concat(TokenTools.getArguments(tokens.slice(argumentStartIndex, argumentEndIndex)));
			
		}
		
		return new FunctionCallSyntax(functionName, functionArguments);
	}
}