package orca.syntax;

import orca.Token;
import orca.TokenTools;
import orca.debug.Debug;

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
		if (tokens.length == 2 && tokens[0].type == Type.Define && tokens[1].type == Type.ID)
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
			Debug.reportError("Syntax error", "structure declaration syntax is not valid.", lineNumber);		
			return null;
		}
		
		return new ClassDeclarationSyntax(tokens[1]);
	}
}