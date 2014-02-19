package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 함수 선언 구문 패턴
 * 
 * 형식: define [Target ->] name(parameters) -> returnType
 * 
 * @author 김 현준
 */
class FunctionDeclarationSyntax implements Syntax {
	
	public var functionName:Token;
	public var returnType:Token;

	public var parameters:Array<Array<Token>>;
	
	public function new(functionName:Token, returnType:Token, parameters:Array<Array<Token>> = null) {
		this.functionName = functionName;
		this.returnType = returnType;
		this.parameters = parameters;
	}	
	
	/**
	 * 토큰열이 함수 선언 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		
		if (!(tokens.length > 0 && tokens[0].type == Type.Define))
			return false;
		
		var case1:Bool = tokens.length > 3 && tokens[1].type == Type.ID && tokens[2].type == Type.Right;
		var case2:Bool = tokens.length > 3 && tokens[1].type == Type.ID && tokens[2].type == Type.ShellOpen;
		
		if (case1 || case2)
			return true;	
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 함수 선언 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):FunctionDeclarationSyntax {
		
		// 최소 구분 특징으로 아래 값을 판단한다.		
		var hasTarget:Bool = tokens[1].type == Type.ID && tokens[2].type == Type.Right;
		var hasParameters:Bool = hasTarget ? tokens[5].type != Type.ShellClose : tokens[3].type != Type.ShellClose;
		var hasReturnType:Bool = tokens[tokens.length - 1].type == Type.ID;
		
		var functionName:Token = tokens[1];
		var parameters:Array<Array<Token>> = new Array<Array<Token>>();
		var returnType:Token = new Token(Type.ID, "void");
		
		if (hasTarget) {
			parameters.push([new Token(Type.ID, "this"), Token.findByType(Type.Colon) , tokens[1]]);
			functionName = tokens[3];
		}
		
		if (hasParameters) {
			
			var parameterStartIndex:Int = 3;			
			if (hasTarget) parameterStartIndex += 2;
			
			var parameterEndIndex:Int = tokens.length - 1;
			if (hasReturnType) parameterEndIndex -= 2;
			
			// 파라미터가 괄호로 싸여있지 않다면 에러.
			if (tokens[parameterStartIndex - 1].type != Type.ShellOpen || tokens[parameterEndIndex].type != Type.ShellClose) {
				
				Debug.reportError("Syntax error", "Parameter declaration must contained within the parantheses", lineNumber);
				return null;
			}			
			functionName = tokens[parameterStartIndex - 2];
			parameters = parameters.concat(TokenTools.getArguments(tokens.slice(parameterStartIndex, parameterEndIndex)));			
		}
		
		if (hasReturnType) {
			if (tokens[tokens.length - 2].type != Type.Right) {
				Debug.reportError("Syntax error", "There is no -> to set return type of function.", lineNumber);
				return null;
			}			
			returnType = tokens[tokens.length - 1];
		}
		
		return new FunctionDeclarationSyntax(functionName, returnType, parameters);
	}
}