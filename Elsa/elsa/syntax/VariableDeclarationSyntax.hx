package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 변수 선언 구문 패턴
 * 
 * 형식: var A:T = I
 * 
 * @author 김 현준
 */
class VariableDeclarationSyntax implements Syntax {

	// 기본 변수 정보
	public var variableName:Token;
	public var variableType:Token;

	// 변수의 초기화 정보
	public var initializer:Array<Token>;
	
	public function new(variableName:Token, variableType:Token, initializer:Array<Token> = null) {
		this.variableName = variableName;
		this.variableType = variableType;
		this.initializer = initializer;
	}	
	
	/**
	 * 토큰열이 변수 선언 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.VARIABLE)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 변수 선언 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):VariableDeclarationSyntax {		

		if (tokens.length < 3) {
			Debug.report("구문 오류", "선언문이 너무 짧습니다.", lineNumber);
			return null;
		}

		// 식별자가 ID형식인지 검사한다.
		if (tokens[1].type != Type.ID) {
			Debug.report("구문 오류", "변수의 식별자가 올바르지 않습니다.", lineNumber);
			return null;
		}

		// 콜론의 사용이 올바른지 체크한다.
		if (tokens[2].type != Type.COLON) {
			Debug.report("구문 오류", "데이터 타입을 지정하기 위한 콜론(':')이 필요합니다.", lineNumber);
			return null;
		}

		// 변수 타입이 ID형식인지 검사한다.
		if (tokens[3].type != Type.ID) {
			Debug.report("구문 오류", "변수의 타입이 올바르지 않습니다.", lineNumber);
			return null;
		}

		// 변수의 초기화문이 존재하는지 확인한다.
		var hasInitializer:Bool = false;
		if (tokens.length > 5) {

			// 초기화문의 형식을 갖추었을 경우
			if (tokens[4].type == Type.ASSIGNMENT) {
				hasInitializer = true;
			}

			// 길기만 하고 형식은 잘못되었을 경우
			else {
				Debug.report("구문 오류", "잘못된 초기화문입니다.", lineNumber);
				return null;
			}
		} else if (tokens.length == 5) {
			Debug.report("구문 오류", "변수 선언문의 끝에 불필요한 추가 문자가 있습니다.", lineNumber);
			return null;
		}
		
		var result:Array<Token> = null;
		if (hasInitializer){
			result = tokens.slice(4, tokens.length);
			result.insert(0, tokens[1]);
		}
		return new VariableDeclarationSyntax(tokens[1], tokens[3], hasInitializer ? result : null);
	}
}