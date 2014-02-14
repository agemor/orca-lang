package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 함수 선언 구문 패턴
 * 
 * 형식: function F (a:A, b:B, c:C, ..., x:X) : R
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
		if (tokens.length > 0 && tokens[0].type == Type.Function)
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
		
		// 괄호가 생략된 형태의 정의인지의 여부
		var isOmittedForm:Bool = false;

		// 매개 변수의 사용 여부
		var hasParameters:Bool = false;

		// 함수 구성 요소
		var functionName:Token;
		var returnType:Token;
		var parameters:Array<Array<Token>> = null;

		// 선언문이 너무 짧을 경우
		if (tokens.length < 6) {

			// 괄호가 생략된 형태의 폼일 경우
			if (tokens.length == 4)
				isOmittedForm = true;
			else {
				Debug.report("Syntax error", "Function declaration statement is too short.", lineNumber);	
				return null;
			}
		}

		// 식별자가 ID형식인지 검사한다.
		if (tokens[1].type != Type.ID) {
			Debug.report("Syntax error", "Function name is not valid", lineNumber);	
			return null;
		}

		// 프로시져 이름 취득
		functionName = tokens[1];

		// 생략된 형태의 선언문일 경우
		if (isOmittedForm) {

			// 프로시져의 리턴 타입을 취득한다.
			if (tokens[2].type != Type.Colon) {
				Debug.report("Syntax error", "There is no colon to set return type of function.", lineNumber);
				return null;
			}

			if (tokens[3].type != Type.ID) {
				Debug.report("Syntax error", "The return type of function is not valid", lineNumber);
				return null;
			}

			// 프로시져 타입 취득
			returnType = tokens[3];
		}

		// 일반적인 형태의 선언문일 경우
		else {

			// 괄호로 열려 있어야 한다.
			if (tokens[2].type != Type.ShellOpen) {
				Debug.report("Syntax error", "Parameter declaration must contained within the parantheses", lineNumber);
				return null;
			}

			// 괄호로 닫혀 있어야 한다.
			if (TokenTools.indexOfShellClose(tokens) == tokens.length - 3) {
				Debug.report("Syntax error", "insert \")\" to complete Expression", lineNumber);	
				return null;
			}

			// 매개 변수를 취득한다.
			parameters = TokenTools.getArguments(tokens.slice(3, tokens.length - 3));

			if (parameters.length == 1 && parameters[0].length == 0)
				hasParameters = false;
			else
				hasParameters = true;
				
			// 프로시져 타입을 취득한다.
			if (tokens[tokens.length - 2].type != Type.Colon) {
				Debug.report("Syntax error", "There is no colon to set return type of function.", lineNumber);
				return null;
			}

			if (tokens[tokens.length - 1].type != Type.ID) {
				Debug.report("Syntax error", "The return type of function is not valid", lineNumber);
				return null;
			}

			returnType = tokens[tokens.length - 1];
		}

		return new FunctionDeclarationSyntax(functionName, returnType, hasParameters ? parameters : new Array<Array<Token>>());
	}
}