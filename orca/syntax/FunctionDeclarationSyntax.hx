package orca.syntax;

import orca.Token;
import orca.TokenTools;
import orca.debug.Debug;

/**
 * 함수 선언 구문 패턴
 * 
 * 형식: define Target.name(parameters) -> returnType
 * 
 * @author 김 현준
 */
class FunctionDeclarationSyntax implements Syntax {
	
	public var functionName:Token;
	public var returnType:Token;
	public var parameters:Array<Array<Token>>;
	
	public function new(functionName:Token, returnType:Token, parameters:Array<Array<Token>>) {
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

		// 기본적인 길이 조건을 체크한다.
		if (tokens.length < 3)
			return false;
		
		// 최소 패턴을 검사한다.
		if (tokens[0].type != Type.Define || tokens[1].type != Type.ID)
			return false;
			
		return true;
	}
	
	/**
	 * 토큰열을 분석하여 함수 선언 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):FunctionDeclarationSyntax {
		
		var functionName:Token = null;
		var parameters:Array<Array<Token>> = null;
		var returnType:Token = null;
		
		// 타겟형과 일반형을 구분한다.
		if (tokens[2].type == Type.Dot) {
			
			functionName = tokens[3];
			var functionTarget:Array<Token> = [new Token(Type.ID, "this"), Token.findByType(Type.Colon) , tokens[1]];
			
			// 길이 조건을 새로 체크한다.
			if (tokens.length < 5) {
				Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
				return null;
			}
			
			if (tokens[3].type != Type.ID) {
				Debug.reportError("Syntax error", "함수에 이름이 없습니다.", lineNumber);
				return null;
			}
			
			if (tokens[4].type != Type.ShellOpen) {
				Debug.reportError("Syntax error", "(가 필요합니다.", lineNumber);
				return null;
			}
			
			var indexOfShellClose:Int = TokenTools.indexOfShellClose(tokens, 5);
			
			if (indexOfShellClose < 0) {
				Debug.reportError("Syntax error", "괄호가 닫히지 않았습니다.", lineNumber);
				return null;
			}
			
			// 리턴 타입 있음
			if (indexOfShellClose != tokens.length - 1) {
				
				// 길이 조건을 새로 체크한다.
				if (tokens.length <= indexOfShellClose + 2 || indexOfShellClose + 2 != tokens.length - 1) {
					Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
					return null;
				}
				
				if (tokens[tokens.length - 2].type != Type.Right || tokens[tokens.length - 1].type != Type.ID) {
					Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
					return null;
				}
				
				returnType = tokens[tokens.length - 1];
			}
			
			// 리턴 타입 없음
			else {
				returnType = new Token(Type.ID, "void");
			}
			
			// 파라미터를 취득한다.
			parameters = TokenTools.split(tokens.slice(5, indexOfShellClose), Type.Comma, true);
			
			// 타겟을 파라미터의 첫 번째에 추가한다.
			parameters.insert(0, functionTarget);
		}		
		
		// 일반형 define name(parameters)->type
		else {
			
			functionName = tokens[1];
			
			// 길이 조건을 다시 체크한다.
			if (tokens.length < 4) {
				Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
				return null;
			}
			
			if (tokens[2].type != Type.ShellOpen) {
				Debug.reportError("Syntax error", "(가 필요합니다.", lineNumber);
				return null;
			}
			
			var indexOfShellClose:Int = TokenTools.indexOfShellClose(tokens, 3);
			
			if (indexOfShellClose < 0) {
				Debug.reportError("Syntax error", "괄호가 닫히지 않았습니다.", lineNumber);
				return null;
			}
			
			// 리턴 타입 있음
			if (indexOfShellClose != tokens.length - 1) {
				
				// 길이 조건을 새로 체크한다.
				if (tokens.length <= indexOfShellClose + 2 || indexOfShellClose + 2 != tokens.length - 1) {
					Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
					return null;
				}
				
				if (tokens[tokens.length - 2].type != Type.Right || tokens[tokens.length - 1].type != Type.ID) {
					Debug.reportError("Syntax error", "Unexpected Token.", lineNumber);
					return null;
				}
				
				returnType = tokens[tokens.length - 1];
			}
			
			// 리턴 타입 없음
			else {
				returnType = new Token(Type.ID, "void");
			}			
			
			// 파라미터를 취득한다.
			parameters = TokenTools.split(tokens.slice(3, indexOfShellClose), Type.Comma, true);
		}
		
		var trimmedParameters:Array<Array<Token>> = new Array<Array<Token>>();
		
		for (i in 0...parameters.length) {
			if (parameters[i].length > 0 ) trimmedParameters.push(parameters[i]);
		}
		
		return new FunctionDeclarationSyntax(functionName, returnType, trimmedParameters);
	}
}