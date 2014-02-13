package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 클래스 선언문 구문 패턴
 * 
 * 형식: class A
 * 
 * @author 김 현준
 */
class ClassDeclarationSyntax implements Syntax {

	public var className:Token; 
	
	public function new(className:Token) {
		this.className = className;
	}	
	
	/**
	 * 토큰열이 클래스 선언 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 0 && tokens[0].type == Type.CLASS)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 클래스 선언 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ClassDeclarationSyntax {
		
		// 토큰의 길이를 검사한다.
		if (tokens.length != 2) {
			Debug.report("구문 오류", "선언문의 형태가 올바르지 않습니다.", lineNumber);		
			return null;
		}

		// 식별자가 ID형식인지 검증한다.
		if (tokens[1].type != Type.ID) {
			Debug.report("구문 오류", "오브젝트의 식별자가 올바르지 않습니다.", lineNumber);		
			return null;
		}
		
		return new ClassDeclarationSyntax(tokens[1]);
	}
}